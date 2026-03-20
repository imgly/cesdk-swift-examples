import Foundation

/// Dimensions for a generated image
public struct ImageSize: Sendable {
  public let width: Int
  public let height: Int

  public var dimensions: (width: Int, height: Int) { (width, height) }

  public static func custom(width: Int, height: Int) -> ImageSize {
    ImageSize(width: width, height: height)
  }
}

/// Style identifier passed to the AI service
public struct AIImageStyle: Sendable {
  public let id: String

  public static func custom(_ id: String) -> AIImageStyle {
    AIImageStyle(id: id)
  }
}

/// Request model for image generation
public struct ImageGenerationRequest: Sendable {
  public let prompt: String
  public let size: ImageSize?
  public let style: AIImageStyle
  public let numberOfImages: Int
  public let hasTransparentBackground: Bool
  public let sourceImageData: Data?
  public let sourceImageURL: String?

  public init(
    prompt: String,
    size: ImageSize?,
    style: AIImageStyle,
    numberOfImages: Int = 1,
    hasTransparentBackground: Bool = false,
    sourceImageData: Data? = nil,
    sourceImageURL: String? = nil
  ) {
    self.prompt = prompt
    self.size = size
    self.style = style
    self.numberOfImages = numberOfImages
    self.hasTransparentBackground = hasTransparentBackground
    self.sourceImageData = sourceImageData
    self.sourceImageURL = sourceImageURL
  }
}
