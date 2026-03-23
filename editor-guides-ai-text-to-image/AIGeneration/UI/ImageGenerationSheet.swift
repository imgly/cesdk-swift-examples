import IMGLYDesignEditor
import SwiftUI

/// A simple wrapper view for image generation
public struct ImageGenerationSheet: View {
  var delegate: any ImageGenerationDelegate
  let configuration: ImageGenerationUIConfiguration

  public init(delegate: any ImageGenerationDelegate, configuration: ImageGenerationUIConfiguration) {
    self.delegate = delegate
    self.configuration = configuration
  }

  // Convenience initializer
  public init(delegate: any ImageGenerationDelegate,
              aiService: AIImageService,
              enablesImageToImage: Bool = true,
              showsFormatSelector: Bool = true) {
    self.delegate = delegate
    configuration = ImageGenerationUIConfiguration(
      for: aiService,
      enablesImageToImage: enablesImageToImage,
      showsFormatSelector: showsFormatSelector,
    )
  }

  public var body: some View {
    ImageGenerationView(
      delegate: delegate,
      configuration: configuration,
    )
  }
}
