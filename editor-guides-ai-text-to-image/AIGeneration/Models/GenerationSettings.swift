import Foundation

/// Defines the type of image generation to perform
public enum GenerationMode: Codable, Sendable {
  /// Generate an image from a text prompt
  case textToImage
  /// Generate an image based on a source image
  case imageToImage
}

/// Settings for image generation
public struct GenerationSettings: Equatable, Codable, Sendable {
  /// The generation mode (text-to-image or image-to-image)
  public var mode: GenerationMode = .textToImage

  /// The output type (image or vector)
  public var outputType: OutputType = .image

  /// The prompt to use for generation
  public var prompt: String = ""

  /// The style to apply for image generation
  public var imageStyle: ImageStyle = .realisticImage

  /// The style to apply for vector generation
  public var vectorStyle: VectorStyle = .vectorIllustration

  /// The format of the generated image
  public var format: FormatOption = .squareHD

  /// Custom dimensions when format is .custom
  public var customWidth: Int = 512
  public var customHeight: Int = 512

  /// The background option for the generated image
  public var background: BackgroundOption = .standard

  /// The source image data for image-to-image generation (for local images)
  public var sourceImageData: Data?

  /// The source image URL for image-to-image generation (for external URLs)
  public var sourceImageURL: String?

  /// Creates a new GenerationSettings instance
  public init() {}

  /// Creates a new GenerationSettings instance with the specified values
  public init(
    mode: GenerationMode,
    outputType: OutputType,
    prompt: String,
    imageStyle: ImageStyle,
    vectorStyle: VectorStyle,
    format: FormatOption,
    background: BackgroundOption
  ) {
    self.mode = mode
    self.outputType = outputType
    self.prompt = prompt
    self.imageStyle = imageStyle
    self.vectorStyle = vectorStyle
    self.format = format
    self.background = background
  }

  /// Returns the current style as a string based on output type
  public var currentStyleId: String {
    switch outputType {
    case .image:
      imageStyle.styleId
    case .vector:
      vectorStyle.styleId
    }
  }

  /// Returns the actual dimensions to use (considering custom dimensions)
  public var actualDimensions: (width: Int, height: Int) {
    if format == .custom {
      (customWidth, customHeight)
    } else {
      format.dimensions
    }
  }

  public static func == (lhs: GenerationSettings, rhs: GenerationSettings) -> Bool {
    lhs.mode == rhs.mode &&
      lhs.outputType == rhs.outputType &&
      lhs.prompt == rhs.prompt &&
      lhs.imageStyle == rhs.imageStyle &&
      lhs.vectorStyle == rhs.vectorStyle &&
      lhs.format == rhs.format &&
      lhs.customWidth == rhs.customWidth &&
      lhs.customHeight == rhs.customHeight &&
      lhs.background == rhs.background
    // Note: We don't compare sourceImage in Equatable
  }

  enum CodingKeys: String, CodingKey {
    case mode, outputType, prompt, imageStyle, vectorStyle, format, customWidth, customHeight, background
  }
}
