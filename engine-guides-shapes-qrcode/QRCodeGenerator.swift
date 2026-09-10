// highlight-qr-imports
import CoreImage.CIFilterBuiltins
import IMGLYEngine
import SwiftUI

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

struct QRCanvasExampleView: View {
  // CE.SDK
  @State private var engine: Engine?
  @State private var scene: DesignBlockID = 0
  @State private var page: DesignBlockID = 0

  // UI state
  @State private var urlString: String = "https://example.com"

  var body: some View {
    VStack(spacing: 16) {
      // Canvas renders the current engine scene
      Group {
        if let engine {
          Canvas(engine: engine, isPaused: .constant(false))
            .frame(minHeight: 280)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
        } else {
          ZStack {
            RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08))
            Text("Canvas will appear after Engine is created")
              .foregroundColor(.secondary)
              .padding()
          }
          .frame(minHeight: 280)
        }
      }

      // Controls
      VStack(spacing: 12) {
        HStack(spacing: 0) {
          TextField("https://example.com", text: $urlString)
          #if os(iOS)
            .autocapitalization(.none)
            .keyboardType(.URL)
          #endif
            .textFieldStyle(.roundedBorder)
          Spacer()

          Button("Insert QR") { Task { await insertQR() } }
            .disabled(engine == nil || page == 0)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
      }
    }
    .padding()
    .onAppear { Task { await setupEngineIfNeeded() } }
  }

  // MARK: - Engine Setup

  @MainActor
  private func setupEngineIfNeeded() async {
    guard engine == nil else { return }
    do {
      let e = try await Engine(license: "<your license key>")
      engine = e
      let s = try e.scene.create()
      scene = s
      let p = try e.block.create(.page)
      try e.block.appendChild(to: s, child: p)
      page = p
    } catch {
      print("Engine setup error:", error)
    }
  }

  // MARK: - Insert QR

  @MainActor
  private func insertQR() async {
    guard let e = engine, page != 0 else { return }
    do {
      _ = try await insertQRCode(
        engine: e,
        page: page,
        urlString: urlString,
        position: CGPoint(x: 200, y: 200),
        size: 180,
      )
    } catch {
      print("Insert QR failed:", error)
    }
  }
}

// MARK: - QR Generation (Core Image)

// highlight-qr-generate
/// Generate a QR code with brand colors.
/// - Parameters:
///   - string: Content to encode (use a full URL with scheme).
///   - correction: Error correction level (L, M, Q, H). "M" is a good default.
///   - scale: Pixel scale factor (increase for print).
///   - foreground: Dark module color.
///   - background: Light background color.
private func makeQRCode(
  from string: String,
  correction: String = "M",
  scale: CGFloat = 10,
  foreground: PlatformColor = .black,
  background: PlatformColor = .white,
) -> PlatformImage? {
  guard let data = string.data(using: .utf8) else { return nil }

  let qr = CIFilter.qrCodeGenerator()
  qr.setValue(data, forKey: "inputMessage")
  qr.setValue(correction, forKey: "inputCorrectionLevel")
  guard let output = qr.outputImage else { return nil }

  // Map black/white to brand colors
  let falseColor = CIFilter.falseColor()
  falseColor.inputImage = output
  #if canImport(UIKit)
    falseColor.color0 = CIColor(color: foreground)
    falseColor.color1 = CIColor(color: background)
  #elseif canImport(AppKit)
    falseColor.color0 = CIColor(color: foreground) ?? CIColor.black
    falseColor.color1 = CIColor(color: background) ?? CIColor.white
  #endif
  guard let colored = falseColor.outputImage else { return nil }

  // Scale up without interpolation
  let scaled = colored.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
  let context = CIContext(options: [.useSoftwareRenderer: false])
  guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }

  #if canImport(UIKit)
    return UIImage(cgImage: cg, scale: 1.0, orientation: .up)
  #elseif canImport(AppKit)
    return NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
  #endif
}

// highlight-qr-generate

// MARK: - CE.SDK Block Creation

// highlight-qr-insert
@MainActor
func insertQRCode(
  engine: Engine,
  page: DesignBlockID,
  urlString: String,
  position: CGPoint = .init(x: 200, y: 200),
  size: CGFloat = 160,
) async throws -> DesignBlockID {
  guard let qr = makeQRCode(from: urlString, correction: "M", scale: 10, foreground: .black, background: .white) else {
    throw NSError(domain: "QR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate QR image"])
  }

  // Get PNG data from the image (platform-specific)
  #if canImport(UIKit)
    guard let png = qr.pngData() else {
      throw NSError(domain: "QR", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode QR as PNG"])
    }
  #elseif canImport(AppKit)
    guard let tiffRepresentation = qr.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffRepresentation),
          let png = bitmap.representation(using: .png, properties: [:]) else {
      throw NSError(domain: "QR", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode QR as PNG"])
    }
  #endif

  let fileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("png")
  try png.write(to: fileURL)

  // Create a visible graphic block with a rect shape
  let graphic = try engine.block.create(.graphic)
  let rectShape = try engine.block.createShape(.rect)
  try engine.block.setShape(graphic, shape: rectShape)

  // Create an image fill and point it to the QR file URL
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setString(imageFill, property: "fill/image/imageFileURI", value: fileURL.absoluteString)
  try engine.block.setFill(graphic, fill: imageFill)

  // Size & position (keep square)
  try engine.block.setWidth(graphic, value: Float(size))
  try engine.block.setHeight(graphic, value: Float(size))
  try engine.block.setPositionX(graphic, value: Float(position.x))
  try engine.block.setPositionY(graphic, value: Float(position.y))

  // highlight-qr-metadata
  // Optional metadata for future updates
  try? engine.block.setMetadata(graphic, key: "qr/url", value: urlString)
  // highlight-qr-metadata

  // Add to page
  try engine.block.appendChild(to: page, child: graphic)

  return graphic
}

// highlight-qr-insert

// highlight-qr-update
/// Update an existing QR code block with a new URL.
/// - Parameters:
///   - engine: The CE.SDK engine instance.
///   - qrBlock: The existing QR code block to update.
///   - newURL: The new URL to encode.
@MainActor
func updateQRCode(engine: Engine, qrBlock: DesignBlockID, newURL: String) throws {
  guard let qr = makeQRCode(from: newURL) else { return }

  // Get PNG data from the image (platform-specific)
  #if canImport(UIKit)
    guard let png = qr.pngData() else { return }
  #elseif canImport(AppKit)
    guard let tiffRepresentation = qr.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffRepresentation),
          let png = bitmap.representation(using: .png, properties: [:]) else { return }
  #endif

  let fileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("png")
  try png.write(to: fileURL)

  let fill = try engine.block.getFill(qrBlock)
  try engine.block.setString(fill, property: "fill/image/imageFileURI", value: fileURL.absoluteString)
  try? engine.block.setMetadata(qrBlock, key: "qr/url", value: newURL)
}

// highlight-qr-update

#Preview {
  QRCanvasExampleView()
}
