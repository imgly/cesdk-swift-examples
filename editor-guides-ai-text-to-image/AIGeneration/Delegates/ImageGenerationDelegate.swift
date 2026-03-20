import Foundation

/// Protocol for handling AI image generation from editor contexts
@MainActor
public protocol ImageGenerationDelegate: AnyObject {
  /// Generate an image with the given settings
  func generateImage(with settings: GenerationSettings) async
}
