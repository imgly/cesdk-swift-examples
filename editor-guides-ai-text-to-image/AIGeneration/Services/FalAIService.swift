@preconcurrency import FalClient
import Foundation
import UIKit

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

  /// Determine MIME type from image data
  private nonisolated func determineMimeType(from data: Data) -> String {
    // Check for PNG signature
    let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47]
    if data.count >= 4 {
      let first4 = data.prefix(4)
      if first4.elementsEqual(pngSignature) {
        return "image/png"
      }
    }

    // Check for JPEG signature
    let jpegSignature: [UInt8] = [0xFF, 0xD8, 0xFF]
    if data.count >= 3 {
      let first3 = data.prefix(3)
      if first3[0] == jpegSignature[0], first3[1] == jpegSignature[1], first3[2] == jpegSignature[2] {
        return "image/jpeg"
      }
    }

    // Default to JPEG if unknown
    return "image/jpeg"
  }

  private nonisolated func compressImageData(
    _ originalData: Data,
    maxSizeBytes: Int = 3 * 1024 * 1024,
    maxDimension: CGFloat = 4096,
    maxMegapixels: CGFloat = 16,
  ) -> (data: Data, mimeType: String)? {
    let originalMimeType = determineMimeType(from: originalData)
    guard let image = UIImage(data: originalData) else {
      return (originalData, originalMimeType)
    }

    let pixelWidth = image.size.width * image.scale
    let pixelHeight = image.size.height * image.scale
    let megapixels = (pixelWidth * pixelHeight) / 1_000_000

    // Already within limits
    let withinLimits = originalData.count <= maxSizeBytes
      && pixelWidth <= maxDimension
      && pixelHeight <= maxDimension
      && megapixels <= maxMegapixels
    if withinLimits {
      return (originalData, originalMimeType)
    }

    // Step 1: Resize if dimensions/megapixels exceed limits
    let resized = resizeIfNeeded(
      image, maxDimension: maxDimension, maxMegapixels: maxMegapixels,
    )

    // Step 2: Encode to fit within byte size limit
    return encodeToFitSize(resized, originalMimeType: originalMimeType, maxSizeBytes: maxSizeBytes)
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

  /// Encodes an image as PNG or JPEG, progressively reducing quality to fit within maxSizeBytes.
  private nonisolated func encodeToFitSize(
    _ image: UIImage,
    originalMimeType: String,
    maxSizeBytes: Int,
  ) -> (data: Data, mimeType: String)? {
    // Try PNG first if original was PNG
    if originalMimeType == "image/png", let pngData = image.pngData(), pngData.count <= maxSizeBytes {
      return (pngData, "image/png")
    }

    // Try JPEG at full quality
    if let jpegData = image.jpegData(compressionQuality: 1.0), jpegData.count <= maxSizeBytes {
      return (jpegData, "image/jpeg")
    }

    // Progressive JPEG compression — target 75% of max for base64 overhead safety
    let targetSize = Int(Double(maxSizeBytes) * 0.75)
    let base64Limit = 1536 * 1024 // 1.5MB base64 data URI limit
    for quality: CGFloat in [0.7, 0.5, 0.3, 0.2, 0.1, 0.05] {
      if let data = image.jpegData(compressionQuality: quality),
         data.count <= targetSize,
         data.base64EncodedString().count + 24 < base64Limit { // +24 for "data:image/jpeg;base64,"
        return (data, "image/jpeg")
      }
    }

    // Last resort: lowest quality
    if let data = image.jpegData(compressionQuality: 0.05) {
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

  /// Compresses and encodes image data as a base64 data URI for the fal.ai API
  private nonisolated func encodeImageAsDataURI(_ sourceImageData: Data) throws -> String {
    let maxSize = 1 * 1024 * 1024 // 1MB
    let maxDimension: CGFloat = 1536
    let maxMegapixels: CGFloat = 16

    guard let compressionResult = compressImageData(
      sourceImageData,
      maxSizeBytes: maxSize,
      maxDimension: maxDimension,
      maxMegapixels: maxMegapixels,
    ) else {
      throw AIServiceError.invalidRequest("Failed to process image data.")
    }

    let (compressedData, mimeType) = compressionResult

    if compressedData.count > maxSize {
      let currentKB = compressedData.count / 1024
      let maxKB = maxSize / 1024
      throw AIServiceError
        .invalidRequest("Image is too large even after compression (\(currentKB)KB). Maximum allowed: \(maxKB)KB")
    }

    // Validate final dimensions
    if let finalImage = UIImage(data: compressedData) {
      let pixelW = finalImage.size.width * finalImage.scale
      let pixelH = finalImage.size.height * finalImage.scale

      if pixelW > maxDimension || pixelH > maxDimension {
        throw AIServiceError
          .invalidRequest("Image dimensions too large: \(Int(pixelW))x\(Int(pixelH))px. Max: \(Int(maxDimension))px")
      }
      if (pixelW * pixelH) / 1_000_000 > maxMegapixels {
        throw AIServiceError
          .invalidRequest("Image resolution too high. Max: \(Int(maxMegapixels))MP")
      }
    }

    let base64String = compressedData.base64EncodedString()
    let dataURI = "data:\(mimeType);base64,\(base64String)"

    let falAILimit = 5 * 1024 * 1024
    if dataURI.utf8.count > falAILimit {
      throw AIServiceError.invalidRequest("Base64 data URI too large. Fal.AI limit: 5MB")
    }

    return dataURI
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
