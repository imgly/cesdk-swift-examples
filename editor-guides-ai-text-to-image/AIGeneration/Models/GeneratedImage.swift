import Foundation

/// Result of image generation
public struct GeneratedImage: Sendable {
  public let imageURL: URL
  public let metadata: ImageMetadata

  public init(imageURL: URL, metadata: ImageMetadata) {
    self.imageURL = imageURL
    self.metadata = metadata
  }
}

/// Metadata about the generated image
public struct ImageMetadata: Sendable {
  public let generationTime: TimeInterval
  public let serviceUsed: String

  public init(
    generationTime: TimeInterval,
    serviceUsed: String
  ) {
    self.generationTime = generationTime
    self.serviceUsed = serviceUsed
  }
}
