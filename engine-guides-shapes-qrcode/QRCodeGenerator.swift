// highlight-qr-imports
import CoreImage.CIFilterBuiltins
import Foundation
import IMGLYEngine

#if canImport(UIKit)
  import UIKit

  private typealias PlatformColor = UIColor
  private typealias PlatformImage = UIImage
#elseif canImport(AppKit)
  import AppKit

  private typealias PlatformColor = NSColor
  private typealias PlatformImage = NSImage
#endif
// highlight-qr-imports

// highlight-qr-generate
/// Generate a QR code image from a string using Core Image.
/// - Parameters:
///   - string: Content to encode; use a full URL with scheme.
///   - correction: Error correction level (L, M, Q, H). "M" is a good default.
///   - scale: Pixel scale factor. Increase for print.
///   - foreground: Dark module color.
///   - background: Light background color.
private func makeQRCode(
  from string: String,
  correction: String = "M",
  scale: CGFloat = 10,
  foreground: PlatformColor = .black,
  background: PlatformColor = .white,
) throws -> PlatformImage {
  guard let data = string.data(using: .utf8) else {
    throw QRGenerationError.invalidInput
  }

  let qr = CIFilter.qrCodeGenerator()
  qr.setValue(data, forKey: "inputMessage")
  qr.setValue(correction, forKey: "inputCorrectionLevel")
  guard let output = qr.outputImage else {
    throw QRGenerationError.filterFailed
  }

  // Map the filter's default black-and-white output to the requested colors.
  let falseColor = CIFilter.falseColor()
  falseColor.inputImage = output
  #if canImport(UIKit)
    falseColor.color0 = CIColor(color: foreground)
    falseColor.color1 = CIColor(color: background)
  #elseif canImport(AppKit)
    falseColor.color0 = CIColor(color: foreground) ?? CIColor.black
    falseColor.color1 = CIColor(color: background) ?? CIColor.white
  #endif
  guard let colored = falseColor.outputImage else {
    throw QRGenerationError.filterFailed
  }

  // Scale without interpolation so QR modules stay crisp.
  let scaled = colored.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
  let context = CIContext(options: [.useSoftwareRenderer: false])
  guard let cg = context.createCGImage(scaled, from: scaled.extent) else {
    throw QRGenerationError.filterFailed
  }

  #if canImport(UIKit)
    return UIImage(cgImage: cg, scale: 1.0, orientation: .up)
  #elseif canImport(AppKit)
    return NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
  #endif
}

private enum QRGenerationError: Error {
  case invalidInput
  case filterFailed
  case encodingFailed
}

// highlight-qr-generate

@MainActor
func insertQRCode(engine: Engine) async throws {
  // Demo scaffolding: create a scene and page so the QR block has a canvas.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-qr-insert
  let qrImage = try makeQRCode(from: "https://img.ly")

  // Both PNG-encoding branches share the same output format.

  #if canImport(UIKit)
    guard let png = qrImage.pngData() else {
      throw QRGenerationError.encodingFailed
    }
  #elseif canImport(AppKit)
    guard let tiff = qrImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
      throw QRGenerationError.encodingFailed
    }
  #endif

  let qrFileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("png")
  try png.write(to: qrFileURL)

  let qrBlock = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(qrBlock, shape: rectShape)

  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: qrFileURL)
  try engine.block.setFill(qrBlock, fill: imageFill)

  try engine.block.setWidth(qrBlock, value: 300)
  try engine.block.setHeight(qrBlock, value: 300)
  try engine.block.setPositionX(qrBlock, value: 250)
  try engine.block.setPositionY(qrBlock, value: 150)

  try engine.block.appendChild(to: page, child: qrBlock)
  // highlight-qr-insert

  // highlight-qr-metadata
  try engine.block.setMetadata(qrBlock, key: "qr/url", value: "https://img.ly")
  // highlight-qr-metadata

  try await engine.captureGuide(page, label: "hero")

  // highlight-qr-update
  let updatedURL = "https://img.ly/showcases"
  let updatedImage = try makeQRCode(from: updatedURL)

  #if canImport(UIKit)
    guard let updatedPng = updatedImage.pngData() else {
      throw QRGenerationError.encodingFailed
    }
  #elseif canImport(AppKit)
    guard let updatedTiff = updatedImage.tiffRepresentation,
          let updatedBitmap = NSBitmapImageRep(data: updatedTiff),
          let updatedPng = updatedBitmap.representation(using: .png, properties: [:]) else {
      throw QRGenerationError.encodingFailed
    }
  #endif

  let updatedFileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("png")
  try updatedPng.write(to: updatedFileURL)

  let fill = try engine.block.getFill(qrBlock)
  try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: updatedFileURL)
  try engine.block.setMetadata(qrBlock, key: "qr/url", value: updatedURL)
  // highlight-qr-update
}
