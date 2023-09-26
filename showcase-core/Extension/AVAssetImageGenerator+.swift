import AVFoundation

public extension AVAssetImageGenerator {
  func generateImage(at time: CMTime) async throws -> (image: CGImage, actualTime: CMTime) {
    if #available(iOS 16, *) {
      return try await image(at: time)
    } else {
      return try await withCheckedThrowingContinuation { continuation in
        generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, actualTime, result, error in
          if result == .succeeded, let image {
            continuation.resume(returning: (image, actualTime))
          } else if let error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(throwing: Error(errorDescription: "Could not generate image."))
          }
        }
      }
    }
  }
}
