import IMGLYEngine

@MainActor
func annotation(engine: Engine) async throws {
  // Resolve the sample video against the engine's base URL. In an app you would
  // point this at your own media URL. This line is example scaffolding, not part
  // of the annotation lesson, so it stays outside the highlighted snippets.
  let baseURL = try engine.guidesBaseURL
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  let page = try createAnnotationScene(engine: engine, videoURL: videoURL)
  let text = try addTextAnnotation(engine: engine, page: page)
  let highlight = try addShapeAnnotation(engine: engine, page: page)
  let annotations = [text, highlight]

  let sync = AnnotationTimelineSync(engine: engine, page: page)
  sync.refresh(annotations)
  try seekToAnnotation(engine: engine, page: page, annotation: highlight)

  _ = try setAnnotationPlayback(engine: engine, page: page, playing: true, looping: true)
  try updateAnnotationText(engine: engine, annotation: text, text: "Replay this part")
  try moveAnnotation(engine: engine, annotation: highlight, x: 780, y: 260)
  try updateAnnotationTiming(engine: engine, annotation: highlight, start: 13.0, duration: 3.0)
  try removeAnnotation(engine: engine, annotation: text)
}

// highlight-annotation-timelinePlacement
@MainActor
private func createAnnotationScene(engine: Engine, videoURL: URL) throws -> DesignBlockID {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 20)

  let video = try engine.block.create(.graphic)
  try engine.block.setShape(video, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(video, fill: videoFill)

  let videoTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: videoTrack)
  try engine.block.appendChild(to: videoTrack, child: video)
  try engine.block.fillParent(videoTrack)

  return page
}

// highlight-annotation-timelinePlacement

// highlight-annotation-textAnnotation
@MainActor
private func addTextAnnotation(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let text = try engine.block.create(.text)
  try engine.block.replaceText(text, text: "Watch this part!")
  try engine.block.setTextFontSize(text, fontSize: 32)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.setPositionX(text, value: 160)
  try engine.block.setPositionY(text, value: 560)

  try engine.block.setTimeOffset(text, offset: 5)
  try engine.block.setDuration(text, duration: 5)

  try engine.block.appendChild(to: page, child: text)
  return text
}

// highlight-annotation-textAnnotation

// highlight-annotation-shapeAnnotation
@MainActor
private func addShapeAnnotation(engine: Engine, page: DesignBlockID) throws -> DesignBlockID {
  let highlight = try engine.block.create(.graphic)
  try engine.block.setShape(highlight, shape: engine.block.createShape(.star))
  try engine.block.setWidth(highlight, value: 140)
  try engine.block.setHeight(highlight, value: 140)
  try engine.block.setPositionX(highlight, value: 700)
  try engine.block.setPositionY(highlight, value: 240)

  let fill = try engine.block.createFill(.color)
  try engine.block.setFill(highlight, fill: fill)
  try engine.block.setFillSolidColor(highlight, r: 1, g: 0, b: 0, a: 1)

  try engine.block.setTimeOffset(highlight, offset: 12)
  try engine.block.setDuration(highlight, duration: 4)

  try engine.block.appendChild(to: page, child: highlight)
  return highlight
}

// highlight-annotation-shapeAnnotation

// highlight-annotation-playbackSync
private struct AnnotationTimelineState {
  var currentTime: Double
  var activeAnnotation: DesignBlockID?
}

@MainActor
private final class AnnotationTimelineSync {
  private let engine: Engine
  private let page: DesignBlockID
  private(set) var state = AnnotationTimelineState(currentTime: 0, activeAnnotation: nil)
  private var pollingTask: Task<Void, Never>?

  init(engine: Engine, page: DesignBlockID) {
    self.engine = engine
    self.page = page
  }

  // Call this from UI code that owns a lifecycle. It polls at a modest interval
  // so the UI stays responsive.
  func start(_ annotations: [DesignBlockID]) {
    pollingTask?.cancel()
    pollingTask = Task { [weak self] in
      while !Task.isCancelled {
        self?.refresh(annotations)
        try? await Task.sleep(nanoseconds: 200_000_000) // ~5 Hz
      }
    }
  }

  func refresh(_ annotations: [DesignBlockID]) {
    let currentTime = (try? engine.block.getPlaybackTime(page)) ?? 0
    let active = annotations.first { annotation in
      guard engine.block.isValid(annotation) else { return false }
      return (try? engine.block.isVisibleAtCurrentPlaybackTime(annotation)) == true
    }
    state = AnnotationTimelineState(currentTime: currentTime, activeAnnotation: active)
  }

  func stop() {
    pollingTask?.cancel()
    pollingTask = nil
  }
}

// highlight-annotation-playbackSync

// highlight-annotation-seek
@MainActor
private func seekToAnnotation(engine: Engine, page: DesignBlockID, annotation: DesignBlockID) throws {
  guard try engine.block.supportsPlaybackTime(page) else { return }

  let start = try engine.block.getTimeOffset(annotation)
  try engine.block.setPlaybackTime(page, time: start)
}

// highlight-annotation-seek

// highlight-annotation-playbackControls
@MainActor
private func setAnnotationPlayback(
  engine: Engine,
  page: DesignBlockID,
  playing: Bool,
  looping: Bool,
) throws -> (isPlaying: Bool, isLooping: Bool) {
  try engine.block.setPlaying(page, enabled: playing)
  let isPlaying = try engine.block.isPlaying(page)

  try engine.block.setLooping(page, looping: looping)
  let isLooping = try engine.block.isLooping(page)

  return (isPlaying, isLooping)
}

// highlight-annotation-playbackControls

// highlight-annotation-editText
@MainActor
private func updateAnnotationText(engine: Engine, annotation: DesignBlockID, text: String) throws {
  try engine.block.replaceText(annotation, text: text)
}

// highlight-annotation-editText

// highlight-annotation-move
@MainActor
private func moveAnnotation(engine: Engine, annotation: DesignBlockID, x: Float, y: Float) throws {
  try engine.block.setPositionX(annotation, value: x)
  try engine.block.setPositionY(annotation, value: y)
}

// highlight-annotation-move

// highlight-annotation-retime
@MainActor
private func updateAnnotationTiming(
  engine: Engine,
  annotation: DesignBlockID,
  start: Double,
  duration: Double,
) throws {
  try engine.block.setTimeOffset(annotation, offset: start)
  try engine.block.setDuration(annotation, duration: duration)
}

// highlight-annotation-retime

// highlight-annotation-remove
@MainActor
private func removeAnnotation(engine: Engine, annotation: DesignBlockID) throws {
  try engine.block.destroy(annotation)
}

// highlight-annotation-remove
