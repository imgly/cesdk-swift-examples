import IMGLYEngine
import IMGLYPhotoEditor
import SwiftUI
import Vision

enum BackgroundRemovalGuideError: Error {
  case badImageURI
  case imageEncodingFailed
}

@MainActor
func performBackgroundRemoval(context: Dock.Context) async {
  let engine = context.engine

  do {
    // 1) Locate an image fill (simple case: use the page’s fill)
    guard let currentPage = try engine.scene.getCurrentPage() else { return }
    let imageFill = try engine.block.getFill(currentPage)
    let fillType = try engine.block.getType(imageFill)
    guard fillType == FillType.image.rawValue else { return }

    // Visual feedback
    try engine.block.setState(imageFill, state: .pending(progress: 0.5))

    // 2) Extract bytes -> UIImage
    let imageData = try await extractImageData(from: imageFill, engine: engine)
    guard let originalImage = UIImage(data: imageData) else {
      try? engine.block.setState(imageFill, state: .ready)
      return
    }

    // 3) Run Vision (iOS 17+)
    guard #available(iOS 17.0, *) else {
      try? engine.block.setState(imageFill, state: .ready)
      return
    }

    guard let cutout = await BackgroundRemoverV2.removeWithForegroundInstanceMask(from: originalImage) else {
      try? engine.block.setState(imageFill, state: .ready)
      return
    }

    // 4) Persist and update the source
    let processedImageURL = try saveImageToCache(cutout)

    // Option A: append to source set (keeps original as a fallback)
    try await engine.block.addImageFileURIToSourceSet(
      imageFill,
      property: "fill/image/sourceSet",
      uri: processedImageURL,
    )

    // Option B: replace the source set entirely (single definitive source)
    /*
     try await engine.block.setSourceSet(
       imageFill,
       property: "fill/image/sourceSet",
       sourceSet: [
         .init(uri: processedImageURL,
               width: Int(cutout.size.width),
               height: Int(cutout.size.height)),
       ],
     )
     */

  } catch {
    // Optionally: present an alert/notice via state
    // print("Background removal failed: \(error)")
  }

  // Always restore the visual state
  do { try engine.block.setState(try engine.block.getFill(try engine.scene.getCurrentPage()!), state: .ready) } catch {}
}

private func extractImageData(from block: DesignBlockID, engine: Engine) async throws -> Data {
  let imageFileURI = try await engine.block.getString(block, property: "fill/image/imageFileURI")
  guard let url = URL(string: imageFileURI) else {
    throw BackgroundRemovalGuideError.badImageURI
  }
  let (data, _) = try await URLSession.shared.data(from: url)
  return data
}

private func saveImageToCache(_ image: UIImage) throws -> URL {
  guard let data = image.pngData() else {
    throw BackgroundRemovalGuideError.imageEncodingFailed
  }
  let cacheURL = try FileManager.default
    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    .appendingPathComponent(UUID().uuidString, conformingTo: .png)
  try data.write(to: cacheURL)
  return cacheURL
}
