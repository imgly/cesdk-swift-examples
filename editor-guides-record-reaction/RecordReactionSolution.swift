import IMGLYCamera
import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct RecordReactionSolution: View {
  // The video the user will react to. In a real app this is supplied by the caller.
  static let baseVideoURL: URL = {
    let host = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.75.0"
    let path = "/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
    return URL(string: host + path)!
  }()

  struct ReactionResult: Identifiable {
    let id = UUID()
    let result: CameraResult
  }

  @State private var isCameraPresented = false
  @State private var reactionResult: ReactionResult?

  var body: some View {
    Button("Record a Reaction") {
      isCameraPresented = true
    }
    .fullScreenCover(isPresented: $isCameraPresented) {
      // highlight-record-reaction-launch
      Camera(
        EngineSettings(license: secrets.licenseKey, userID: "<your unique user id>"),
        config: CameraConfiguration(allowModeSwitching: false),
        mode: .reaction(.vertical, video: Self.baseVideoURL, positionsSwapped: false),
      ) { cameraResult in
        // highlight-record-reaction-launch
        // highlight-record-reaction-handle-result
        switch cameraResult {
        case let .success(value):
          reactionResult = ReactionResult(result: value)
          isCameraPresented = false

        case let .failure(error) where error == .cancelled:
          isCameraPresented = false

        case let .failure(error):
          print(error.localizedDescription)
          isCameraPresented = false
        }
        // highlight-record-reaction-handle-result
      }
    }
    .fullScreenCover(item: $reactionResult) { reactionResult in
      ModalEditor {
        Editor(EngineSettings(license: secrets.licenseKey, userID: "<your unique user id>"))
          .imgly.configuration {
            VideoEditorConfiguration { builder in
              builder.onCreate { engine, _ in
                // highlight-record-reaction-default-build
                try await engine.createScene(from: reactionResult.result)
                // highlight-record-reaction-default-build
                try await VideoEditorConfiguration.defaultLoadAssetSources(engine)
              }
            }
          }
      }
    }
  }
}

// Customization path: build the scene manually instead of calling
// `engine.createScene(from:)`. Copy these helpers when you need to tweak
// the layout, durations, or block hierarchy the default integration produces.

// highlight-record-reaction-custom-build-scene
@MainActor
private func buildReactionSceneManually(engine: Engine, result: CameraResult) async throws {
  guard
    case let .reaction(video, reaction) = result,
    let baseVideo = video.videos.first,
    let firstReactionVideo = reaction.first?.videos.first
  else {
    return
  }

  try await engine.scene.create(fromVideo: baseVideo.url)

  guard let page = try engine.scene.getCurrentPage() else { return }
  let sceneFrame = baseVideo.rect.union(firstReactionVideo.rect)
  setFrame(engine: engine, designBlock: page, rect: sceneFrame)

  guard let baseVideoBlock = try engine.block.find(byType: .graphic).first else { return }
  setFrame(engine: engine, designBlock: baseVideoBlock, rect: baseVideo.rect)

  let reactionTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: reactionTrack)
  // highlight-record-reaction-custom-build-scene

  // highlight-record-reaction-custom-sync-duration
  let baseFill = try engine.block.getFill(baseVideoBlock)
  try await engine.block.forceLoadAVResource(baseFill)
  let baseDurationSeconds = try engine.block.getAVResourceTotalDuration(baseFill)

  var reactionOffsetSeconds = 0.0
  for recording in reaction {
    let remainingSeconds = baseDurationSeconds - reactionOffsetSeconds
    if remainingSeconds <= 0.0 { break }

    guard let reactionVideo = recording.videos.first else { continue }
    let reactionBlock = try addReactionRecording(
      engine: engine,
      recording: recording,
      reactionVideo: reactionVideo,
      parent: reactionTrack,
    )

    let recordingDurationSeconds = recording.duration.seconds
    let clipDurationSeconds = min(recordingDurationSeconds, remainingSeconds)
    if clipDurationSeconds < recordingDurationSeconds {
      try engine.block.setDuration(reactionBlock, duration: clipDurationSeconds)
    }
    reactionOffsetSeconds += clipDurationSeconds
  }

  let finalDurationSeconds = min(reactionOffsetSeconds, baseDurationSeconds)
  try engine.block.setTrimOffset(baseFill, offset: 0.0)
  try engine.block.setTrimLength(baseFill, length: finalDurationSeconds)
  try engine.block.setDuration(baseVideoBlock, duration: finalDurationSeconds)
}

// highlight-record-reaction-custom-sync-duration

// highlight-record-reaction-custom-add-clips
@MainActor
@discardableResult
private func addReactionRecording(
  engine: Engine,
  recording: Recording,
  reactionVideo: Recording.Video,
  parent: DesignBlockID,
) throws -> DesignBlockID {
  let reactionBlock = try engine.block.create(.graphic)
  let shape = try engine.block.createShape(.rect)
  try engine.block.setShape(reactionBlock, shape: shape)
  setFrame(engine: engine, designBlock: reactionBlock, rect: reactionVideo.rect)

  let fill = try engine.block.createFill(.video)
  try engine.block.setURL(fill, property: "fill/video/fileURI", value: reactionVideo.url)
  try engine.block.setFill(reactionBlock, fill: fill)

  try engine.block.setDuration(reactionBlock, duration: recording.duration.seconds)
  try engine.block.appendChild(to: parent, child: reactionBlock)
  return reactionBlock
}

// highlight-record-reaction-custom-add-clips

// highlight-record-reaction-custom-rect-frame
@MainActor
private func setFrame(engine: Engine, designBlock: DesignBlockID, rect: CGRect) {
  try? engine.block.setWidth(designBlock, value: Float(rect.width))
  try? engine.block.setHeight(designBlock, value: Float(rect.height))
  try? engine.block.setPositionX(designBlock, value: Float(rect.minX))
  try? engine.block.setPositionY(designBlock, value: Float(rect.minY))
}

// highlight-record-reaction-custom-rect-frame
