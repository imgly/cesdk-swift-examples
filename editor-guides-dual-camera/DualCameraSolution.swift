import IMGLYCamera
import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct DualCameraSolution: View {
  struct DualCameraResult: Identifiable {
    let id = UUID()
    let result: CameraResult
  }

  @State private var isCameraPresented = false
  @State private var dualCameraResult: DualCameraResult?

  var body: some View {
    Group {
      // highlight-dualCamera-modeCheck
      if Camera.isModeSupported(.dualCamera()) {
        Button("Record with Dual Camera") {
          isCameraPresented = true
        }
      } else {
        Text("Dual Camera isn't supported on this device.")
      }
      // highlight-dualCamera-modeCheck
    }
    .fullScreenCover(isPresented: $isCameraPresented) {
      // highlight-dualCamera-launch
      Camera(
        EngineSettings(license: secrets.licenseKey, userID: "<your unique user id>"),
        config: CameraConfiguration(allowModeSwitching: false),
        mode: .dualCamera(.vertical),
      ) { cameraResult in
        // highlight-dualCamera-launch
        // highlight-dualCamera-handleResult
        switch cameraResult {
        case let .success(value):
          dualCameraResult = DualCameraResult(result: value)
          isCameraPresented = false

        case let .failure(error) where error == .cancelled:
          isCameraPresented = false

        case let .failure(error):
          print(error.localizedDescription)
          isCameraPresented = false
        }
        // highlight-dualCamera-handleResult
      }
    }
    .fullScreenCover(item: $dualCameraResult) { dualCameraResult in
      ModalEditor {
        Editor(EngineSettings(license: secrets.licenseKey, userID: "<your unique user id>"))
          .imgly.configuration {
            VideoEditorConfiguration { builder in
              builder.onCreate { engine, _ in
                // highlight-dualCamera-openInEditor
                try await engine.createScene(from: dualCameraResult.result)
                // highlight-dualCamera-openInEditor
                try await VideoEditorConfiguration.defaultLoadAssetSources(engine)
              }
            }
          }
      }
    }
  }
}

// Customization path: build the scene manually instead of calling
// `engine.createScene(from:)`. Copy this when you need a custom composition
// (picture-in-picture, animated split, etc.) — change the `rect` of a feed
// before passing it to `setFrame`.

// highlight-dualCamera-customBuildScene
@MainActor
private func buildDualCameraSceneManually(engine: Engine, result: CameraResult) async throws {
  guard case let .capture(captures) = result else { return }
  let recordings = captures.videos
  guard
    let firstRecording = recordings.first,
    let firstVideo = firstRecording.videos.first
  else {
    return
  }

  try await engine.scene.create(fromVideo: firstVideo.url)

  guard let page = try engine.scene.getCurrentPage() else { return }
  let sceneFrame = firstRecording.videos
    .map(\.rect)
    .reduce(CGRect.null) { $0.union($1) }
  try setFrame(engine: engine, designBlock: page, rect: sceneFrame)

  guard let firstBlock = try engine.block.find(byType: .graphic).first else { return }
  try setFrame(engine: engine, designBlock: firstBlock, rect: firstVideo.rect)
  try engine.block.setDuration(firstBlock, duration: firstRecording.duration.seconds)

  for video in firstRecording.videos.dropFirst() {
    let block = try engine.block.create(.graphic)
    let shape = try engine.block.createShape(.rect)
    try engine.block.setShape(block, shape: shape)
    try setFrame(engine: engine, designBlock: block, rect: video.rect)

    let fill = try engine.block.createFill(.video)
    try engine.block.setURL(fill, property: "fill/video/fileURI", value: video.url)
    try engine.block.setFill(block, fill: fill)

    try engine.block.setDuration(block, duration: firstRecording.duration.seconds)
    try engine.block.appendChild(to: page, child: block)
  }
}

// highlight-dualCamera-customBuildScene

// highlight-dualCamera-customRectFrame
@MainActor
private func setFrame(engine: Engine, designBlock: DesignBlockID, rect: CGRect) throws {
  try engine.block.setWidth(designBlock, value: Float(rect.width))
  try engine.block.setHeight(designBlock, value: Float(rect.height))
  try engine.block.setPositionX(designBlock, value: Float(rect.minX))
  try engine.block.setPositionY(designBlock, value: Float(rect.minY))
}

// highlight-dualCamera-customRectFrame
