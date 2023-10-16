import Foundation
import IMGLYEngine

@MainActor
func useCamera(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.createVideo()
  let stack = try engine.block.find(byType: .stack).first!
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: stack, child: page)

  let pixelStreamFill = try engine.block.createFill("pixelStream")
  try engine.block.setFill(page, fill: pixelStreamFill)

  try engine.block.appendEffect(page, effectID: try engine.block.createEffect(type: "half_tone"))
  // highlight-setup

  // highlight-orientation
  try engine.block.setEnum(
    pixelStreamFill,
    property: "fill/pixelStream/orientation",
    value: "UpMirrored"
  )
  // highlight-orientation

  // highlight-camera
  let camera = try Camera()

  Task {
    try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
    for try await event in camera.captureVideo() {
      // highlight-camera
      switch event {
      // highlight-setNativePixelBuffer
      case let .frame(buffer):
        try engine.block.setNativePixelBuffer(pixelStreamFill, buffer: buffer)
      // highlight-setNativePixelBuffer
      case let .videoCaptured(url):
        // Use a `VideoFill` for the recorded video file.
        let videoFill = try engine.block.createFill("video")
        try engine.block.setFill(page, fill: videoFill)
        try engine.block.setString(
          videoFill,
          property: "fill/video/fileURI",
          value: url.absoluteString
        )
      }
    }
  }

  // Stop capturing after 5 seconds.
  Task {
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 5)
    camera.stopCapturing()
  }
}
