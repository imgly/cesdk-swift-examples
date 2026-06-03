import CoreGraphics
import Foundation
import IMGLYEngine

@MainActor
func toRawData(engine: Engine) async throws {
  let assetsBase = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0/assets"
  try engine.editor.setSettingString("basePath", value: assetsBase)
  let sceneURL = URL(string: "\(assetsBase)/ly.img.template/templates/cesdk_postcard_1.scene")!
  try await engine.scene.load(from: sceneURL)

  let page = try engine.scene.getPages().first!
  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-toRawData-export
  let width = 1920
  let height = 1080
  let pixelData: Blob = try await engine.block.export(
    page,
    mimeType: .binary,
    options: ExportOptions(targetWidth: Float(width), targetHeight: Float(height)),
  )
  try pixelData.write(to: exportsDirectory.appendingPathComponent("design.rgba"))
  // highlight-toRawData-export

  // highlight-toRawData-readPixels
  let centerX = width / 2
  let centerY = height / 2
  let centerIndex = (centerY * width + centerX) * 4
  let red = pixelData[centerIndex]
  let green = pixelData[centerIndex + 1]
  let blue = pixelData[centerIndex + 2]
  let alpha = pixelData[centerIndex + 3]
  print("Center pixel RGBA: \(red), \(green), \(blue), \(alpha)")
  // highlight-toRawData-readPixels

  // highlight-toRawData-toCGImage
  let colorSpace = CGColorSpaceCreateDeviceRGB()
  let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
  let provider = CGDataProvider(data: pixelData as NSData)!
  let cgImage = CGImage(
    width: width,
    height: height,
    bitsPerComponent: 8,
    bitsPerPixel: 32,
    bytesPerRow: width * 4,
    space: colorSpace,
    bitmapInfo: bitmapInfo,
    provider: provider,
    decode: nil,
    shouldInterpolate: false,
    intent: .defaultIntent,
  )!
  // highlight-toRawData-toCGImage

  // highlight-toRawData-targetSize
  let resizedOptions = ExportOptions(targetWidth: 960, targetHeight: 540)
  let resizedPixelData = try await engine.block.export(page, mimeType: .binary, options: resizedOptions)
  try resizedPixelData.write(to: exportsDirectory.appendingPathComponent("design.thumbnail.rgba"))
  // highlight-toRawData-targetSize

  // highlight-toRawData-checkLimits
  let maxExportSize = try engine.editor.getMaxExportSize()
  print("Maximum export dimension: \(maxExportSize)px")
  // highlight-toRawData-checkLimits

  _ = cgImage
}
