@preconcurrency import AVFoundation
import ImageIO
import SwiftUI

/// Small still images of the picked media for the grids, the loading screen and the timeline strip.
/// A video shows its middle frame. Results are cached by URL. The decoders are `nonisolated async`, so they
/// run off the main actor.
@MainActor
enum MemoriesThumbnails {
  private static let cache = NSCache<NSURL, UIImage>()
  private static var frameFiles: [URL: URL] = [:]

  static func image(for item: MemoriesMediaItem) async -> UIImage? {
    if let cached = cache.object(forKey: item.url as NSURL) {
      return cached
    }
    let image = item.isVideo
      ? await middleFrame(of: item.url, maxPixelSize: 256)
      : await downsampledImage(at: item.url, maxPixelSize: 256)
    if let image {
      cache.setObject(image, forKey: item.url as NSURL)
    }
    return image
  }

  /// The middle frame of a video as a PNG file, for an engine image fill.
  static func videoFrameFile(for url: URL) async -> URL? {
    if let file = frameFiles[url], FileManager.default.fileExists(atPath: file.path) {
      return file
    }
    let file = await writePNG(middleFrame(of: url, maxPixelSize: 512))
    frameFiles[url] = file
    return file
  }

  private nonisolated static func writePNG(_ image: UIImage?) async -> URL? {
    guard let data = image?.pngData() else { return nil }
    let file = FileManager.default.temporaryDirectory.appendingPathComponent("memories-frame-\(UUID().uuidString).png")
    return (try? data.write(to: file)) == nil ? nil : file
  }

  private nonisolated static func downsampledImage(at url: URL, maxPixelSize: Int) async -> UIImage? {
    let options = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
    ] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
    return UIImage(cgImage: image)
  }

  private nonisolated static func middleFrame(of url: URL, maxPixelSize: Int) async -> UIImage? {
    let asset = AVURLAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: maxPixelSize, height: maxPixelSize)
    guard let duration = try? await asset.load(.duration),
          let frame = try? await generator.image(at: CMTimeMultiplyByRatio(duration, multiplier: 1, divisor: 2))
    else { return nil }
    return UIImage(cgImage: frame.image)
  }
}

/// A square-cropped thumbnail that loads in the background and shows a placeholder until then.
struct MemoriesThumbnailView: View {
  let item: MemoriesMediaItem
  @State private var image: UIImage?

  var body: some View {
    Color(.secondarySystemBackground)
      .overlay {
        if let image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        }
      }
      .clipped()
      .task(id: item.url) {
        image = await MemoriesThumbnails.image(for: item)
      }
  }
}
