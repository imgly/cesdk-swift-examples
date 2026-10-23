import Foundation
import IMGLYEngine

struct FillsLottieGuideResult {
  let duration: Double
  let errorCode: EngineErrorCode?
  let pngData: Data
}

// highlight-fillsLottie-document
// A 3 second Lottie at 30 frames per second. Its image layer fades in a
// photo and zooms into it. The asset names the photo by an absolute URL.
private let lottieDocument = """
{
  "v": "5.7.0", "fr": 30, "ip": 0, "op": 90, "w": 1000, "h": 1000,
  "assets": [{
    "id": "photo", "w": 2500, "h": 1667, "u": "",
    "p": "https://img.ly/static/ubq_samples/sample_1.jpg", "e": 0
  }],
  "layers": [{
    "ty": 2, "refId": "photo", "ip": 0, "op": 90, "st": 0,
    "ks": {
      "a": { "a": 0, "k": [1250, 833] },
      "p": { "a": 0, "k": [500, 500] },
      "s": { "a": 1, "k": [{ "t": 0, "s": [60, 60] }, { "t": 90, "s": [80, 80] }] },
      "o": { "a": 1, "k": [{ "t": 0, "s": [0] }, { "t": 30, "s": [100] }] }
    }
  }]
}
"""
// highlight-fillsLottie-document

@MainActor
func fillsLottie(engine: Engine) async throws -> FillsLottieGuideResult {
  // highlight-fillsLottie-setup
  // A page of 3 seconds, the length of the animation
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1000)
  try engine.block.setHeight(page, value: 1000)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setDuration(page, duration: 3)
  // highlight-fillsLottie-setup

  // highlight-fillsLottie-buffer
  // A buffer holds the document in memory and gives it a URL
  let lottieURL = engine.editor.createBuffer()
  try engine.editor.setBufferData(url: lottieURL, offset: 0, data: Data(lottieDocument.utf8))
  // highlight-fillsLottie-buffer

  // highlight-fillsLottie-fill
  // A video fill plays the Lottie. Set a hosted .json or .lottie URL the same way.
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 1000)
  try engine.block.setHeight(block, value: 1000)
  let fill = try engine.block.createFill(.video)
  try engine.block.setURL(fill, property: "fill/video/fileURI", value: lottieURL)
  try engine.block.setFill(block, fill: fill)
  try engine.block.appendChild(to: page, child: block)
  try engine.block.setDuration(block, duration: 3)
  // highlight-fillsLottie-fill

  // highlight-fillsLottie-load
  // The load finishes when the Lottie and the images it references are loaded
  try await engine.block.forceLoadAVResource(fill)
  let duration = try engine.block.getAVResourceTotalDuration(fill)
  print(duration) // 3.0
  // highlight-fillsLottie-load

  // highlight-fillsLottie-exportFrame
  // Seek the page to 1.5 seconds and export that frame
  try engine.block.setPlaybackTime(page, time: 1.5)
  let pngData = try await engine.block.export(page, mimeType: .png)
  print(!pngData.isEmpty) // true
  // highlight-fillsLottie-exportFrame

  try await engine.captureGuide(data: pngData, label: "hero", mimeType: .png)

  // highlight-fillsLottie-errors
  // A file that is not a Lottie or a video does not load
  let brokenURL = engine.editor.createBuffer()
  try engine.editor.setBufferData(url: brokenURL, offset: 0, data: Data("not a Lottie".utf8))
  let brokenFill = try engine.block.createFill(.video)
  try engine.block.setURL(brokenFill, property: "fill/video/fileURI", value: brokenURL)
  var errorCode: EngineErrorCode?
  do {
    try await engine.block.forceLoadAVResource(brokenFill)
  } catch let error as EngineError {
    errorCode = error.catalogCode
    print(errorCode == .editorResourceLoadFailed) // true
  }
  try engine.block.destroy(brokenFill)
  try engine.editor.destroyBuffer(url: brokenURL)
  // highlight-fillsLottie-errors

  return FillsLottieGuideResult(
    duration: duration,
    errorCode: errorCode,
    pngData: pngData,
  )
}
