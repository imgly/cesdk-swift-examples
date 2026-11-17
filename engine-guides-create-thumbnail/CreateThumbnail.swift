import Foundation
import IMGLYEngine

@MainActor
func createThumbnail(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL
  let outputDirectory = FileManager.default.temporaryDirectory

  // Demo scaffolding: build a design (a photo with a title banner) so the
  // exported thumbnails preview real content. In your app you start from a
  // scene the user is already editing.
  let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")
  try await engine.scene.create(fromImage: imageURL)
  guard let designPage = try engine.scene.getCurrentPage() else {
    fatalError("Expected create(fromImage:) to create a page.")
  }
  // A design scene from an image keeps font sizes in points; pin them to pixels
  // so the title below is sized in the same unit as the page dimensions.
  try engine.scene.setFontSizeUnit(.px)
  let designWidth = try engine.block.getWidth(designPage)
  let designHeight = try engine.block.getHeight(designPage)

  let banner = try engine.block.create(.graphic)
  try engine.block.setShape(banner, shape: engine.block.createShape(.rect))
  let bannerFill = try engine.block.createFill(.color)
  try engine.block.setColor(bannerFill, property: "fill/color/value", color: .rgba(r: 0.05, g: 0.09, b: 0.16, a: 0.72))
  try engine.block.setFill(banner, fill: bannerFill)
  try engine.block.setWidth(banner, value: designWidth)
  try engine.block.setHeight(banner, value: designHeight * 0.22)
  try engine.block.setPositionX(banner, value: 0)
  try engine.block.setPositionY(banner, value: designHeight * 0.78)
  try engine.block.appendChild(to: designPage, child: banner)

  let title = try engine.block.create(.text)
  try engine.block.replaceText(title, text: "Coastal Escape")
  try engine.block.setTextColor(title, color: .rgba(r: 1, g: 1, b: 1, a: 1))
  try engine.block.setTextFontSize(title, fontSize: designHeight * 0.09)
  try engine.block.setHeightMode(title, mode: .auto)
  try engine.block.setWidth(title, value: designWidth * 0.86)
  try engine.block.setPositionX(title, value: designWidth * 0.07)
  try engine.block.setPositionY(title, value: designHeight * 0.84)
  try engine.block.appendChild(to: designPage, child: title)

  try await engine.captureGuide(designPage, label: "hero")

  // highlight-createThumbnail-selectPage
  let page = try engine.scene.getCurrentPage() ?? engine.scene.getPages().first
  guard let page else {
    fatalError("Load a scene with at least one page before exporting a thumbnail.")
  }
  // highlight-createThumbnail-selectPage

  // highlight-createThumbnail-export
  let thumbnail = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(targetWidth: 400, targetHeight: 300),
  )
  print("Thumbnail: \(thumbnail.count) bytes")
  // highlight-createThumbnail-export

  // highlight-createThumbnail-jpeg
  let jpegThumbnail = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.8, targetWidth: 400, targetHeight: 300),
  )
  print("JPEG thumbnail: \(jpegThumbnail.count) bytes")
  // highlight-createThumbnail-jpeg

  // highlight-createThumbnail-png
  let pngThumbnail = try await engine.block.export(
    page,
    mimeType: .png,
    options: ExportOptions(pngCompressionLevel: 6, targetWidth: 400, targetHeight: 300),
  )
  print("PNG thumbnail: \(pngThumbnail.count) bytes")
  // highlight-createThumbnail-png

  // highlight-createThumbnail-webp
  let webpThumbnail = try await engine.block.export(
    page,
    mimeType: .webp,
    options: ExportOptions(webpQuality: 0.85, targetWidth: 400, targetHeight: 300),
  )
  print("WebP thumbnail: \(webpThumbnail.count) bytes")
  // highlight-createThumbnail-webp

  // highlight-createThumbnail-multiple
  let targetSizes: [(width: Float, height: Float)] = [(150, 150), (400, 300), (800, 600)]
  var responsiveSet: [Data] = []
  for size in targetSizes {
    let sized = try await engine.block.export(
      page,
      mimeType: .jpeg,
      options: ExportOptions(jpegQuality: 0.8, targetWidth: size.width, targetHeight: size.height),
    )
    responsiveSet.append(sized)
    print("\(Int(size.width))x\(Int(size.height)): \(sized.count) bytes")
  }
  // highlight-createThumbnail-multiple

  // highlight-createThumbnail-save
  let savedThumbnail = try await engine.block.export(
    page,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.8, targetWidth: 400, targetHeight: 300),
  )
  let fileURL = outputDirectory.appendingPathComponent("thumbnail.jpg")
  try savedThumbnail.write(to: fileURL)
  // highlight-createThumbnail-save

  // highlight-createThumbnail-video
  let videoScene = try engine.scene.createVideo()
  let videoPage = try engine.block.create(.page)
  try engine.block.appendChild(to: videoScene, child: videoPage)
  try engine.block.setWidth(videoPage, value: 1280)
  try engine.block.setHeight(videoPage, value: 720)
  try engine.block.setDuration(videoPage, duration: 10)

  let clip = try engine.block.create(.graphic)
  try engine.block.setShape(clip, shape: engine.block.createShape(.rect))
  let clipFill = try engine.block.createFill(.video)
  try engine.block.setURL(
    clipFill,
    property: "fill/video/fileURI",
    value: baseURL.appendingPathComponent(
      "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
    ),
  )
  try engine.block.setFill(clip, fill: clipFill)
  try engine.block.setWidth(clip, value: 1280)
  try engine.block.setHeight(clip, value: 720)
  try engine.block.appendChild(to: videoPage, child: clip)

  try await engine.block.forceLoadAVResource(clipFill)
  if try engine.block.supportsPlaybackTime(videoPage) {
    try engine.block.setPlaybackTime(videoPage, time: 2.0)
  }

  let videoThumbnail = try await engine.block.export(
    videoPage,
    mimeType: .jpeg,
    options: ExportOptions(jpegQuality: 0.8, targetWidth: 400, targetHeight: 225),
  )
  try videoThumbnail.write(to: outputDirectory.appendingPathComponent("video-thumbnail.jpg"))
  // highlight-createThumbnail-video
}
