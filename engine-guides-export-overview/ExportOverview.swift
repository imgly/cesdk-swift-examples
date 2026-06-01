import Foundation
import IMGLYEngine

@MainActor
func exportOverview(engine: Engine) async throws {
  // Demo scaffolding: build a two-page scene with renderable content so every
  // highlighted snippet has something to export. In your app you would start
  // from a scene already loaded into the editor instead.
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.setDuration(page, duration: 1.0)
  try engine.block.appendChild(to: scene, child: page)

  let rectangle = try engine.block.create(.graphic)
  try engine.block.setShape(rectangle, shape: engine.block.createShape(.rect))
  let rectangleFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    rectangleFill,
    property: "fill/color/value",
    color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0),
  )
  try engine.block.setFill(rectangle, fill: rectangleFill)
  try engine.block.setPositionX(rectangle, value: 100)
  try engine.block.setPositionY(rectangle, value: 100)
  try engine.block.setWidth(rectangle, value: 600)
  try engine.block.setHeight(rectangle, value: 400)
  try engine.block.appendChild(to: page, child: rectangle)

  let secondPage = try engine.block.create(.page)
  try engine.block.setWidth(secondPage, value: 800)
  try engine.block.setHeight(secondPage, value: 600)
  try engine.block.setDuration(secondPage, duration: 1.0)
  try engine.block.appendChild(to: scene, child: secondPage)

  let ellipse = try engine.block.create(.graphic)
  try engine.block.setShape(ellipse, shape: engine.block.createShape(.ellipse))
  let ellipseFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    ellipseFill,
    property: "fill/color/value",
    color: .rgba(r: 0.95, g: 0.2, b: 0.2, a: 1.0),
  )
  try engine.block.setFill(ellipse, fill: ellipseFill)
  try engine.block.setPositionX(ellipse, value: 100)
  try engine.block.setPositionY(ellipse, value: 100)
  try engine.block.setWidth(ellipse, value: 600)
  try engine.block.setHeight(ellipse, value: 400)
  try engine.block.appendChild(to: secondPage, child: ellipse)

  // Audio block backed by an in-memory buffer so the audio export below has
  // something to read without making a network request.
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)
  let audioBuffer = engine.editor.createBuffer()
  try engine.editor.setBufferLength(url: audioBuffer, length: 96000)
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioBuffer)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportOverview-png
  let pngOptions = ExportOptions(pngCompressionLevel: 9)
  let pngBlob = try await engine.block.export(page, mimeType: .png, options: pngOptions)
  try pngBlob.write(to: exportsDirectory.appendingPathComponent("design.png"))
  // highlight-exportOverview-png

  // highlight-exportOverview-jpeg
  let jpegOptions = ExportOptions(jpegQuality: 0.9)
  let jpegBlob = try await engine.block.export(page, mimeType: .jpeg, options: jpegOptions)
  try jpegBlob.write(to: exportsDirectory.appendingPathComponent("design.jpg"))
  // highlight-exportOverview-jpeg

  // highlight-exportOverview-webp
  let webpOptions = ExportOptions(webpQuality: 1.0)
  let webpBlob = try await engine.block.export(page, mimeType: .webp, options: webpOptions)
  try webpBlob.write(to: exportsDirectory.appendingPathComponent("design.webp"))
  // highlight-exportOverview-webp

  // highlight-exportOverview-svg
  let svgBlob = try await engine.block.export(page, mimeType: .svg)
  try svgBlob.write(to: exportsDirectory.appendingPathComponent("design.svg"))
  // highlight-exportOverview-svg

  // highlight-exportOverview-pdf
  let pdfOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let pdfBlob = try await engine.block.export(page, mimeType: .pdf, options: pdfOptions)
  try pdfBlob.write(to: exportsDirectory.appendingPathComponent("design.pdf"))
  // highlight-exportOverview-pdf

  // highlight-exportOverview-colorMask
  let maskedBlobs = try await engine.block.exportWithColorMask(
    page,
    mimeType: .png,
    maskColorR: 1.0,
    maskColorG: 0.0,
    maskColorB: 0.0,
  )
  try maskedBlobs[0].write(to: exportsDirectory.appendingPathComponent("design.masked.png"))
  try maskedBlobs[1].write(to: exportsDirectory.appendingPathComponent("design.alpha.png"))
  // highlight-exportOverview-colorMask

  // highlight-exportOverview-video
  let videoOptions = VideoExportOptions(
    h264Profile: .main,
    framerate: 30,
    targetWidth: 1280,
    targetHeight: 720,
  )
  let videoStream = try await engine.block.exportVideo(page, mimeType: .mp4, options: videoOptions)
  for try await event in videoStream {
    switch event {
    case let .progress(rendered, encoded, total):
      print("Video export: \(encoded)/\(total) frames encoded (\(rendered) rendered)")
    case let .finished(video):
      try video.write(to: exportsDirectory.appendingPathComponent("design.mp4"))
    }
  }
  // highlight-exportOverview-video

  // highlight-exportOverview-audio
  let audioOptions = AudioExportOptions(skipEncoding: true)
  let audioStream = try await engine.block.exportAudio(audioBlock, mimeType: .wav, options: audioOptions)
  for try await event in audioStream {
    if case let .finished(audio) = event {
      try audio.write(to: exportsDirectory.appendingPathComponent("design.wav"))
    }
  }
  // highlight-exportOverview-audio

  // highlight-exportOverview-targetSize
  let resizedOptions = ExportOptions(targetWidth: 1080, targetHeight: 1080)
  let resizedBlob = try await engine.block.export(page, mimeType: .png, options: resizedOptions)
  try resizedBlob.write(to: exportsDirectory.appendingPathComponent("design.1080.png"))
  // highlight-exportOverview-targetSize

  // highlight-exportOverview-checkLimits
  let maxExportSize = try engine.editor.getMaxExportSize()
  let availableMemory = try? engine.editor.getAvailableMemory()
  print("Max export size: \(maxExportSize)px")
  if let availableMemory {
    print("Available memory: \(availableMemory) bytes")
  }
  // highlight-exportOverview-checkLimits
}
