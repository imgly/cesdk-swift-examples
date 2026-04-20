@preconcurrency import FalClient
import Foundation
import UIKit

/// fal.ai image-to-image limits (from API docs):
/// - File size: < 5 MB
/// - Resolution: < 16 MP
/// - Max dimension: < 4096 px
/// Reserve ~100KB for non-image request params (prompt, style, format, etc.).
private let falMaxRequestBytes = 5 * 1024 * 1024
private let falParamReserve = 100 * 1024
private let maxDataURIBytes = falMaxRequestBytes - falParamReserve

/// FalAIService with built-in configuration
@MainActor
public final class FalAIService: AIImageService {
  // MARK: - Properties

  private let model: FalModel
  private let client: any Client

  /// Delegate transparency support to the model
  public var supportsTransparentBackground: Bool {
    model.supportsTransparentBackground
  }

  /// Delegate vector support to the model
  public var supportsVectorOutput: Bool {
    model.supportsVectorOutput
  }

  // MARK: - Models

  public enum FalModel: String, Sendable {
    case recraftV3 = "fal-ai/recraft-v3"
    case recraftV3ImageToImage = "fal-ai/recraft/v3/image-to-image"
    case fluxSchnell = "fal-ai/flux/schnell"
    case fluxPro = "fal-ai/flux/pro"
    case fluxDev = "fal-ai/flux/dev"
    case stableDiffusion = "fal-ai/stable-diffusion-xl"

    var displayName: String {
      switch self {
      case .recraftV3: "Recraft V3 (High Quality)"
      case .recraftV3ImageToImage: "Recraft V3 Image-to-Image"
      case .fluxSchnell: "Flux Schnell (Fast)"
      case .fluxPro: "Flux Pro (High Quality)"
      case .fluxDev: "Flux Dev"
      case .stableDiffusion: "Stable Diffusion XL"
      }
    }

    /// Model capability: transparent background support
    var supportsTransparentBackground: Bool {
      switch self {
      case .recraftV3, .recraftV3ImageToImage:
        // Recraft V3 does NOT support transparent backgrounds
        false
      case .fluxSchnell, .fluxPro, .fluxDev:
        // Flux models support transparency through alpha channel
        true
      case .stableDiffusion:
        // Stable Diffusion XL supports transparency
        true
      }
    }

    /// Model capability: vector output support
    var supportsVectorOutput: Bool {
      switch self {
      case .recraftV3, .recraftV3ImageToImage:
        // Recraft V3 supports SVG vector output
        true
      case .fluxSchnell, .fluxPro, .fluxDev, .stableDiffusion:
        // Other models only support raster output
        false
      }
    }

    /// Model capability: maximum resolution
    var maxResolution: (width: Int, height: Int) {
      switch self {
      case .recraftV3, .recraftV3ImageToImage:
        // RecraftV3 limits
        (1820, 1820) // Max dimension in either direction
      case .fluxSchnell, .fluxPro, .fluxDev:
        (1920, 1080)
      case .stableDiffusion:
        (1024, 1024)
      }
    }

    /// Model capability: supported aspect ratios
    var supportedAspectRatios: [String] {
      switch self {
      case .recraftV3, .recraftV3ImageToImage:
        ["1:1", "4:3", "3:4", "16:9", "9:16"]
      case .fluxSchnell, .fluxPro, .fluxDev:
        ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9", "9:21"]
      case .stableDiffusion:
        ["1:1", "4:3", "3:4", "16:9", "9:16"]
      }
    }
  }

  // MARK: - Initialization

  /// Initialize with model and proxy URL
  public init(model: FalModel = .recraftV3, proxyURL: String) {
    self.model = model
    client = FalClient.withProxy(proxyURL)
  }

  /// Initialize with model and API key
  public init(model: FalModel = .recraftV3, apiKey: String) {
    self.model = model
    client = FalClient.withCredentials(.keyPair(apiKey))
  }

  // MARK: - AIImageService Protocol Implementation

  public nonisolated(nonsending) func generateImage(with request: ImageGenerationRequest) async throws
    -> GeneratedImage {
    // Capture @MainActor properties before crossing isolation boundary
    let modelDisplayName = model.displayName
    let currentModel = model
    let currentClient = await client

    let startTime = Date()

    // Use image-to-image endpoint when source image exists
    let modelToUse: FalModel = (request.sourceImageData != nil || request.sourceImageURL != nil)
      ? .recraftV3ImageToImage : currentModel

    let arguments = try buildFalRequest(from: request)
    let jsonData = try JSONSerialization.data(withJSONObject: arguments)
    let result = try await currentClient.subscribe(
      to: modelToUse.rawValue,
      input: try Payload.create(fromJSON: jsonData),
      pollInterval: .seconds(1),
      timeout: .seconds(120),
      includeLogs: false,
      onQueueUpdate: { @Sendable _ in },
    )

    let imageUrl = try extractImageUrl(from: result)

    let metadata = ImageMetadata(
      generationTime: Date().timeIntervalSince(startTime),
      serviceUsed: "fal.ai - \(modelDisplayName)",
    )

    return GeneratedImage(imageURL: imageUrl, metadata: metadata)
  }

  // MARK: - Private Helpers

  /// Determine MIME type from image data magic bytes.
  /// Detects PNG, JPEG, and HEIC; defaults to JPEG for unknown formats.
  private nonisolated func determineMimeType(from data: Data) -> String {
    guard data.count >= 4 else { return "image/jpeg" }

    let header = [UInt8](data.prefix(12))

    // PNG: 89 50 4E 47
    if header[0] == 0x89, header[1] == 0x50, header[2] == 0x4E, header[3] == 0x47 {
      return "image/png"
    }

    // JPEG: FF D8 FF
    if header[0] == 0xFF, header[1] == 0xD8, header[2] == 0xFF {
      return "image/jpeg"
    }

    // HEIC/HEIF: ISO BMFF files have "ftyp" at offset 4; check the major brand at offset 8
    // to distinguish HEIC from other ISOBMFF formats (MP4, MOV, 3GP, etc.).
    if data.count >= 12, header[4] == 0x66, header[5] == 0x74, header[6] == 0x79, header[7] == 0x70 {
      let brand = String(bytes: header[8 ... 11], encoding: .ascii) ?? ""
      let heicBrands: Set<String> = ["heic", "heix", "mif1", "msf1", "hevc", "hevx"]
      if heicBrands.contains(brand) {
        return "image/heic"
      }
    }

    return "image/jpeg"
  }

  private nonisolated func compressImageData(
    _ originalData: Data,
    maxSizeBytes: Int = 1 * 1024 * 1024,
    maxDimension: CGFloat = 1024,
    maxMegapixels: CGFloat = 1,
  ) -> (data: Data, mimeType: String)? {
    let originalMimeType = determineMimeType(from: originalData)
    guard let image = UIImage(data: originalData) else {
      return nil
    }

    let pixelWidth = image.size.width * image.scale
    let pixelHeight = image.size.height * image.scale
    let megapixels = (pixelWidth * pixelHeight) / 1_000_000

    let needsReEncode = originalMimeType != "image/jpeg" && originalMimeType != "image/png"

    let withinLimits = originalData.count <= maxSizeBytes
      && pixelWidth <= maxDimension
      && pixelHeight <= maxDimension
      && megapixels <= maxMegapixels
    if withinLimits, !needsReEncode {
      return (originalData, originalMimeType)
    }

    // Step 1: Resize if dimensions/megapixels exceed limits
    let resized = resizeIfNeeded(
      image, maxDimension: maxDimension, maxMegapixels: maxMegapixels,
    )

    // Step 2: Encode to fit within byte size limit.
    // For HEIC input, treat as JPEG since we're re-encoding anyway.
    let targetMimeType = needsReEncode ? "image/jpeg" : originalMimeType
    return encodeToFitSize(resized, originalMimeType: targetMimeType, maxSizeBytes: maxSizeBytes)
  }

  /// Resizes an image if it exceeds dimension or megapixel limits.
  private nonisolated func resizeIfNeeded(
    _ image: UIImage, maxDimension: CGFloat, maxMegapixels: CGFloat,
  ) -> UIImage {
    let pixelWidth = image.size.width * image.scale
    let pixelHeight = image.size.height * image.scale
    let megapixels = (pixelWidth * pixelHeight) / 1_000_000

    var scale: CGFloat = 1.0
    if pixelWidth > maxDimension || pixelHeight > maxDimension {
      scale = min(maxDimension / pixelWidth, maxDimension / pixelHeight)
    }
    if megapixels > maxMegapixels {
      scale = min(scale, sqrt(maxMegapixels / megapixels))
    }

    guard scale < 1.0 else { return image }

    // Use scale=1 so size is treated as pixels, not points
    let newSize = CGSize(width: pixelWidth * scale, height: pixelHeight * scale)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1.0
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }

  /// Encodes an image to fit within maxSizeBytes.
  /// Strategy: keep full resolution with quality reduction → reduce dimensions only if needed.
  private nonisolated func encodeToFitSize(
    _ image: UIImage,
    originalMimeType: String,
    maxSizeBytes: Int,
  ) -> (data: Data, mimeType: String)? {
    func fitsLimits(_ data: Data) -> Bool {
      data.count <= maxSizeBytes && (data.count * 4 / 3) + 24 < maxDataURIBytes
    }

    let pixelWidth = image.size.width * image.scale
    let pixelHeight = image.size.height * image.scale
    let isPNG = originalMimeType == "image/png"

    func scaled(by factor: CGFloat) -> UIImage {
      let newSize = CGSize(width: pixelWidth * factor, height: pixelHeight * factor)
      let format = UIGraphicsImageRendererFormat()
      format.scale = 1.0
      return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
      }
    }

    // 1. Try original format at full size
    if isPNG, let pngData = image.pngData(), fitsLimits(pngData) {
      return (pngData, "image/png")
    }

    for quality: CGFloat in [0.4, 0.3, 0.2] {
      if let data = image.jpegData(compressionQuality: quality), fitsLimits(data) {
        return (data, "image/jpeg")
      }
    }

    var lastResized: UIImage?
    for scaleFactor: CGFloat in [0.75, 0.5, 0.35, 0.25] {
      let resized = scaled(by: scaleFactor)
      lastResized = resized

      if let jpegData = resized.jpegData(compressionQuality: 0.4), fitsLimits(jpegData) {
        return (jpegData, "image/jpeg")
      }
    }

    // 4. Absolute fallback: smallest size + low quality JPEG
    if let smallest = lastResized, let data = smallest.jpegData(compressionQuality: 0.1) {
      return (data, "image/jpeg")
    }

    return nil
  }

  private nonisolated func buildFalRequest(from request: ImageGenerationRequest) throws -> [String: Any] {
    var arguments: [String: Any] = [:]

    arguments["prompt"] = request.prompt
    arguments["style"] = request.style.id

    // Branch-specific parameters
    if let sourceImageURL = request.sourceImageURL {
      // Image-to-image with external URL
      arguments["image_url"] = sourceImageURL
      arguments["controls_scale"] = 0.85

    } else if let sourceImageData = request.sourceImageData {
      // Image-to-image with local image (base64 encoded)
      arguments["image_url"] = try encodeImageAsDataURI(sourceImageData)

    } else {
      // Text-to-image
      arguments["num_images"] = request.numberOfImages
      arguments["enable_safety_checker"] = true

      if request.hasTransparentBackground {
        arguments["output_format"] = "png"
      }
    }

    // Shared: pass image_size if provided
    if let size = request.size {
      if let formatSize = getRecraftV3SizeId(from: size) {
        arguments["image_size"] = formatSize
      } else {
        let dims = size.dimensions
        arguments["image_size"] = ["width": dims.width, "height": dims.height]
      }
    }

    return arguments
  }

  private nonisolated func encodeImageAsDataURI(_ sourceImageData: Data) throws -> String {
    guard let (compressedData, mimeType) = compressImageData(
      sourceImageData,
      maxSizeBytes: 1 * 1024 * 1024,
      maxDimension: 1024,
      maxMegapixels: 1,
    ) else {
      throw AIServiceError.invalidRequest("Failed to process image data.")
    }

    let base64String = compressedData.base64EncodedString()
    return "data:\(mimeType);base64,\(base64String)"
  }

  private nonisolated func extractImageUrl(from result: Payload) throws -> URL {
    guard case let .array(images) = result["images"],
          let firstImage = images.first,
          case let .dict(imageDict) = firstImage,
          case let .string(imageUrlString) = imageDict["url"],
          let imageUrl = URL(string: imageUrlString) else {
      if case let .string(imageUrlString) = result["image"],
         let imageUrl = URL(string: imageUrlString) {
        return imageUrl
      }

      throw AIServiceError.generationFailed("Failed to extract image URL")
    }

    return imageUrl
  }

  /// Map ImageSize to RecraftV3 predefined size ID when possible
  private nonisolated func getRecraftV3SizeId(from size: ImageSize) -> String? {
    let dims = size.dimensions

    // Map to predefined RecraftV3 sizes
    switch (dims.width, dims.height) {
    case (1024, 1024):
      return "square_hd"
    case (512, 512):
      return "square"
    case (1024, 1365):
      return "portrait_4_3"
    case (1024, 1820):
      return "portrait_16_9"
    case (1365, 1024):
      return "landscape_4_3"
    case (1820, 1024):
      return "landscape_16_9"
    default:
      return nil // Custom size
    }
  }
}
