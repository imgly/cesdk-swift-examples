import Foundation
import IMGLYEngine

/// Shared utilities for AI image generation
public enum ImageGenerationUtils {
  // MARK: - Request Building

  /// Convert GenerationSettings to ImageGenerationRequest
  public static func createRequest(
    from settings: GenerationSettings,
    includeSize: Bool = true,
  ) -> ImageGenerationRequest {
    let size: ImageSize? = includeSize ? mapSettingsToImageSize(settings) : nil

    let imageStyle: AIImageStyle = if settings.outputType == .image {
      .custom(settings.imageStyle.styleId)
    } else {
      .custom(settings.vectorStyle.styleId)
    }

    return ImageGenerationRequest(
      prompt: settings.prompt,
      size: size,
      style: imageStyle,
      hasTransparentBackground: settings.background == .transparent,
      sourceImageData: settings.sourceImageData,
      sourceImageURL: settings.sourceImageURL,
    )
  }

  // MARK: - Mapping Helpers

  /// Map GenerationSettings to ImageSize
  public static func mapSettingsToImageSize(_ settings: GenerationSettings) -> ImageSize {
    if settings.format == .custom {
      return .custom(width: settings.customWidth, height: settings.customHeight)
    } else {
      let dims = settings.actualDimensions
      return .custom(width: dims.width, height: dims.height)
    }
  }
}
