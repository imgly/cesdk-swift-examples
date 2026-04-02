import Foundation

/// Protocol defining the interface for AI image generation services
@MainActor
public protocol AIImageService {
  /// Whether the service supports transparent backgrounds
  var supportsTransparentBackground: Bool { get }

  /// Whether the service supports vector output
  var supportsVectorOutput: Bool { get }

  /// Generate an image based on the provided request
  func generateImage(with request: ImageGenerationRequest) async throws -> GeneratedImage
}

/// Errors thrown by AI image generation services
public enum AIServiceError: LocalizedError {
  case invalidRequest(String)
  case generationFailed(String)

  public var errorDescription: String? {
    switch self {
    case let .invalidRequest(reason):
      "Invalid request: \(reason)"
    case let .generationFailed(reason):
      "Image generation failed: \(reason)"
    }
  }
}
