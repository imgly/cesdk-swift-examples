import IMGLYEditor
import IMGLYEngine
import PhotosUI
import SwiftUI

/// The state of the Memories flow: the picked media on the selection screen, and the slideshow
/// editor's playback, overlay and style state. The engine stays the source of truth for the scene,
/// so the editor state is read back from it instead of mirrored.
@MainActor
final class MemoriesModel: ObservableObject {
  enum Screen {
    case selection, editor
  }

  @Published var screen = Screen.selection

  // MARK: - Selection screen

  @Published var picker = MemoriesMediaDraft()
  @Published var title = ""
  @Published private(set) var isImporting = false

  /// Imports newly picked media into `draft`.
  func importMedia(_ pickerItems: [PhotosPickerItem], into draft: ReferenceWritableKeyPath<MemoriesModel,
    MemoriesMediaDraft>) async {
    guard !pickerItems.isEmpty else { return }
    isImporting = true
    let items = await MemoriesMediaImport.items(from: pickerItems, firstID: self[keyPath: draft].nextID)
    self[keyPath: draft].add(items)
    isImporting = false
  }

  // MARK: - Editor lifecycle

  @Published private(set) var isEditorLoading = false
  private var loadingStart = Date()
  private var engine: Engine?
  private var eventHandler: EditorEventHandler?

  func openEditor() {
    loadingStart = Date()
    isEditorLoading = true
    isPreviewMode = false
    isMediaOverlayPresented = false
    stripItems = []
    screen = .editor
  }

  func closeEditor() {
    previewTask?.cancel()
    engine = nil
    eventHandler = nil
    screen = .selection
  }

  /// Called from `onCreate` once the scene exists.
  func attach(_ engine: Engine) async {
    self.engine = engine
    styleThumbnails = (try? await MemoriesStyleApplier.thumbnails(engine)) ?? [:]
  }

  /// Called from `onLoaded`. The tasks run until the editor closes.
  func editorDidLoad(_ context: OnLoaded.Context) {
    eventHandler = context.eventHandler
    let engine = context.engine
    refreshTimeline()
    try? engine.block.setLooping(page(), looping: true)
    isLooping = true
    volume = (try? engine.block.getVolume(page())) ?? 1

    context.task { [weak self] in
      let remaining = MemoriesConstants.minimumLoadingDuration - Date().timeIntervalSince(self?.loadingStart ?? Date())
      if remaining > 0 {
        try await Task.sleep(for: .seconds(remaining))
      }
      self?.isEditorLoading = false
    }
    context.task { [weak self] in
      while !Task.isCancelled {
        self?.pollPlayback()
        try await Task.sleep(for: .milliseconds(100))
      }
    }
    context.task { [weak self] in
      for await _ in engine.editor.onHistoryUpdatedWithKind {
        self?.refreshTimeline()
      }
    }
    context.task {
      for await events in engine.event.subscribe(to: []) {
        Self.adoptNewAudio(engine, events: events)
      }
    }
  }

  /// Without this the loading screen stays up when `onCreate` fails.
  func editorDidFail() {
    isEditorLoading = false
  }

  private func page() throws -> DesignBlockID {
    guard let page = try engine?.scene.getCurrentPage() else { throw EditorError("No page was found.") }
    return page
  }

  /// A new audio block replaces the earlier ones, so the slideshow has one soundtrack. The editor
  /// selects a block it adds, but the soundtrack has no place on the canvas, so it is deselected and
  /// cannot be selected again.
  private static func adoptNewAudio(_ engine: Engine, events: [BlockEvent]) {
    let audioType = DesignBlockType.audio.rawValue
    for event in events where event.type == .created {
      guard (try? engine.block.getType(event.block)) == audioType else { continue }
      try? engine.block.setSelected(event.block, selected: false)
      try? engine.block.setScopeEnabled(event.block, key: "editor/select", enabled: false)
      guard let parent = try? engine.block.getParent(event.block),
            let siblings = try? engine.block.getChildren(parent) else { continue }
      for sibling in siblings where sibling != event.block && (try? engine.block.getType(sibling)) == audioType {
        try? engine.block.destroy(sibling)
      }
    }
  }

  // MARK: - Playback

  @Published private(set) var isPlaying = false
  @Published private(set) var isLooping = true
  @Published private(set) var volume: Float = 1
  @Published private(set) var playbackTime: Double = 0
  @Published private(set) var duration: Double = 0

  private func pollPlayback() {
    guard let engine, let page = try? page() else { return }
    let time = (try? engine.block.getPlaybackTime(page)) ?? 0
    let playing = (try? engine.block.isPlaying(page)) ?? false
    let total = (try? engine.block.getDuration(page)) ?? 0
    // Assign only changes, otherwise every poll redraws the views that observe the model.
    if time != playbackTime {
      playbackTime = time
    }
    if playing != isPlaying {
      isPlaying = playing
    }
    if total != duration {
      duration = total
    }
  }

  func setPlaying(_ playing: Bool) {
    guard let engine, let page = try? page() else { return }
    try? engine.block.setPlaying(page, enabled: playing)
    isPlaying = playing
  }

  func restart() {
    seek(to: 0)
    setPlaying(false)
  }

  func seek(to time: Double) {
    guard let engine, let page = try? page() else { return }
    try? engine.block.setPlaybackTime(page, time: time)
    playbackTime = time
  }

  func toggleLoop() {
    guard let engine, let page = try? page(), let looping = try? engine.block.isLooping(page) else { return }
    try? engine.block.setLooping(page, looping: !looping)
    isLooping = !looping
  }

  func setVolume(_ volume: Float) {
    guard let engine, let page = try? page() else { return }
    try? engine.block.setVolume(page, volume: volume)
    self.volume = volume
  }

  // MARK: - Fullscreen preview

  @Published private(set) var isPreviewMode = false
  /// Cancelled on the next toggle, so a fast double tap cannot enter preview after leaving it.
  private var previewTask: Task<Void, Never>?

  func enterPreview() {
    guard let engine else { return }
    previewTask?.cancel()
    isPreviewMode = true
    for block in engine.block.findAllSelected() {
      try? engine.block.setSelected(block, selected: false)
    }
    eventHandler?.send(.closeSheet)
    previewTask = Task { [weak self] in
      // Lets the dock and the bottom panel animate out before the canvas grows.
      try? await Task.sleep(for: .milliseconds(200))
      guard let self, !Task.isCancelled, isPreviewMode else { return }
      eventHandler?.send(.setViewMode(.preview))
      // The editor pauses while it switches the view mode, so playback starts after the switch.
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled, isPreviewMode else { return }
      setPlaying(true)
    }
  }

  func exitPreview() {
    previewTask?.cancel()
    isPreviewMode = false
    eventHandler?.send(.setViewMode(.edit))
  }

  // MARK: - Timeline strip

  /// Built here rather than in the strip, because the strip redraws on every playback poll.
  @Published private(set) var stripItems: [MemoriesStripItem] = []

  /// Reads the strip's clips back from the tracks, after any change to the scene, including Undo.
  func refreshTimeline() {
    guard let engine, let page = try? page(), let tracks = try? MemoriesScene.findTracks(engine) else {
      stripItems = []
      return
    }
    activeStyleID = MemoriesStyleApplier.appliedStyleID(engine, page: page)
    stripItems = MemoriesStripItem.items(
      clips: (try? MemoriesScene.readTimelineClips(engine, tracks: tracks)) ?? [],
      titleClearTime: try? MemoriesScene.readTitleClearTime(engine, page: page, tracks: tracks),
    )
  }

  // MARK: - Media overlay

  @Published private(set) var isMediaOverlayPresented = false
  /// The staged media of the in-editor media grid. Edits reach the tracks only on Apply.
  @Published var mediaOverlay = MemoriesMediaDraft()

  /// Opens the grid with the media read from the tracks and pauses playback.
  func openMediaOverlay() {
    guard let engine, let tracks = try? MemoriesScene.findTracks(engine) else { return }
    mediaOverlay = MemoriesMediaDraft(items: (try? MemoriesScene.readMediaItems(engine, tracks: tracks)) ?? [])
    isMediaOverlayPresented = true
    setPlaying(false)
  }

  func cancelMediaOverlay() {
    isMediaOverlayPresented = false
  }

  /// Writes the staged media into the tracks, then applies the active style again, because new clips
  /// start full-bleed and without effects. The style pass adds the one undo step for both.
  func applyMediaOverlay() async {
    guard !isApplying, let engine, let page = try? page(),
          let tracks = try? MemoriesScene.findTracks(engine) else { return }
    isApplying = true
    defer { isApplying = false }
    let draft = mediaOverlay
    let style = MemoriesStyles.style(id: activeStyleID)
    do {
      try await MemoriesScene.applyDraft(engine, page: page, tracks: tracks, items: draft.items,
                                         hasTitle: !title.isEmpty, transition: style.transition)
      try await MemoriesStyleApplier.apply(style, engine: engine, page: page)
      picker = MemoriesMediaDraft(items: draft.items)
      isMediaOverlayPresented = false
    } catch {
      eventHandler?.send(.showErrorAlert(error))
    }
    didChangeScene()
  }

  // MARK: - Styles

  /// The style the scene carries, read back after every change, Undo included.
  @Published private(set) var activeStyleID = MemoriesStyles.default.id
  /// Picker thumbnails from the style asset source, keyed by style ID.
  @Published private(set) var styleThumbnails: [String: URL] = [:]
  /// Set while a style or the media grid is applied. Both edit the same clips across awaits, so a
  /// second apply that starts meanwhile works on blocks the first one destroys.
  @Published private(set) var isApplying = false

  func applyStyle(id: String) async {
    guard !isApplying, let engine, let page = try? page() else { return }
    isApplying = true
    defer { isApplying = false }
    do {
      try await MemoriesStyleApplier.apply(MemoriesStyles.style(id: id), engine: engine, page: page)
    } catch {
      eventHandler?.send(.showErrorAlert(error))
    }
    didChangeScene()
  }

  private func didChangeScene() {
    refreshTimeline()
    // Restyling re-times the montage, which stops playback.
    pollPlayback()
  }
}
