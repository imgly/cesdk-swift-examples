import Foundation
import IMGLYEngine

@MainActor
func usingCamera(engine: Engine) async throws {
  // highlight-record-video-setup
  try engine.scene.createVideo()
  let stack = try engine.block.find(byType: .stack).first!
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: stack, child: page)

  let pixelStreamFill = try engine.block.createFill(.pixelStream)
  try engine.block.setFill(page, fill: pixelStreamFill)

  try engine.block.appendEffect(page, effectID: try engine.block.createEffect(.halfTone))
  // highlight-record-video-setup

  // highlight-record-video-orientation
  try engine.block.setEnum(
    pixelStreamFill,
    property: "fill/pixelStream/orientation",
    value: "UpMirrored",
  )
  // highlight-record-video-orientation

  // highlight-record-video-camera
  let camera = try Camera()

  Task {
    try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
    for try await event in camera.captureVideo() {
      // highlight-record-video-camera
      switch event {
      // highlight-record-video-update-fill
      case let .frame(buffer):
        try engine.block.setNativePixelBuffer(pixelStreamFill, buffer: buffer)
      // highlight-record-video-update-fill
      // highlight-record-video-playback
      case let .videoCaptured(url):
        // Use a `VideoFill` for the recorded video file.
        let videoFill = try engine.block.createFill(.video)
        try engine.block.setFill(page, fill: videoFill)
        try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: url)
        // highlight-record-video-playback
      }
    }
  }

  // highlight-record-video-stop
  // Stop capturing after 5 seconds.
  Task {
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
    camera.stopCapturing()
  }
  // highlight-record-video-stop
}
