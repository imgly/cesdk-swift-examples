@preconcurrency import CoreImage
import Foundation
import UIKit
@preconcurrency import Vision

/// Background removal utility using Apple's Vision framework.
/// This class is more focused on face and body detection, since you have control about this code you can change based
/// on your needs
@preconcurrency
enum BackgroundRemover {
  // MARK: - Vision Requests Configuration

  /// Vision request for detecting faces in images
  private static let faceDetectionRequest: VNDetectFaceRectanglesRequest = {
    let request = VNDetectFaceRectanglesRequest()
    request.revision = VNDetectFaceRectanglesRequestRevision3
    return request
  }()

  /// Vision request for detecting human bodies in images
  private static let bodyDetectionRequest: VNDetectHumanRectanglesRequest = {
    let request = VNDetectHumanRectanglesRequest()
    request.revision = VNDetectHumanRectanglesRequestRevision2
    return request
  }()

  /// Vision request for generating person segmentation masks
  private static let personSegmentationRequest: VNGeneratePersonSegmentationRequest = {
    let request = VNGeneratePersonSegmentationRequest()
    request.qualityLevel = .accurate // Use highest quality setting
    request.outputPixelFormat = kCVPixelFormatType_OneComponent8
    request.revision = VNGeneratePersonSegmentationRequestRevision1
    return request
  }()

  // MARK: - Public Interface

  // highlight-remove-background
  static func removeBackground(from image: UIImage) async -> UIImage? {
    // Convert UIImage to CIImage for processing
    guard let ciImage = CIImage(image: image) else {
      debugPrint("❌ Failed to convert UIImage to CIImage")
      return nil
    }

    return await withCheckedContinuation { continuation in
      Task {
        // Step 1: Generate person segmentation mask
        guard let maskImage = await generatePersonMask(from: ciImage) else {
          debugPrint("❌ Failed to generate person mask")
          continuation.resume(returning: nil)
          return
        }

        // Step 2: Apply mask to remove background
        guard let resultCIImage = applyTransparencyMask(maskImage, to: ciImage) else {
          debugPrint("❌ Failed to apply transparency mask")
          continuation.resume(returning: nil)
          return
        }

        // Step 3: Convert result back to UIImage
        guard let resultUIImage = convertToUIImage(resultCIImage) else {
          debugPrint("❌ Failed to convert result to UIImage")
          continuation.resume(returning: nil)
          return
        }
        continuation.resume(returning: resultUIImage)
      }
    }
  }

  // highlight-remove-background

  // MARK: - Private Implementation

  // highlight-generate-mask
  private static func generatePersonMask(from image: CIImage) async -> CIImage? {
    await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        let requestHandler = VNSequenceRequestHandler()
        do {
          try requestHandler.perform([
            faceDetectionRequest,
            bodyDetectionRequest,
            personSegmentationRequest,
          ], on: image)

          // Validate that a person was detected
          let faces = faceDetectionRequest.results ?? []
          let bodies = bodyDetectionRequest.results ?? []
          guard !faces.isEmpty || !bodies.isEmpty else {
            continuation.resume(returning: nil)
            return
          }

          // Extract the segmentation mask
          guard let maskPixelBuffer = personSegmentationRequest.results?.first?.pixelBuffer else {
            continuation.resume(returning: nil)
            return
          }

          var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
          let scaleTransform = calculateScaleTransform(from: maskImage.extent.size, to: image.extent.size)
          maskImage = maskImage.transformed(by: scaleTransform)
          continuation.resume(returning: maskImage)
        } catch {
          continuation.resume(returning: nil)
        }
      }
    }
  }

  // highlight-generate-mask

  // highlight-apply-mask
  private static func applyTransparencyMask(_ mask: CIImage, to image: CIImage) -> CIImage? {
    guard let blendFilter = CIFilter(name: "CIBlendWithRedMask") else { return nil }
    blendFilter.setDefaults()
    blendFilter.setValue(image, forKey: kCIInputImageKey)
    let transparentBackground = CIImage(color: CIColor.clear).cropped(to: image.extent)
    blendFilter.setValue(transparentBackground, forKey: kCIInputBackgroundImageKey)
    blendFilter.setValue(mask, forKey: kCIInputMaskImageKey)
    return blendFilter.outputImage
  }

  // highlight-apply-mask

  /// Converts a CIImage to UIImage.
  private static func convertToUIImage(_ ciImage: CIImage) -> UIImage? {
    let context = CIContext(options: [.useSoftwareRenderer: false])
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }

  /// Calculates the transform needed to scale one size to match another.
  private static func calculateScaleTransform(from fromSize: CGSize, to toSize: CGSize) -> CGAffineTransform {
    let scaleX = toSize.width / fromSize.width
    let scaleY = toSize.height / fromSize.height
    return CGAffineTransform(scaleX: scaleX, y: scaleY)
  }
}
