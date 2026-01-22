@preconcurrency import CoreImage
import Foundation
import UIKit
@preconcurrency import Vision

/// Background removal utility using Apple's Vision framework.
/// This class is more focused on face and body detection, since you have control about this code you can change based
/// on your needs
///
/// This class demonstrates how to:
/// - Use Vision framework for person detection and segmentation
/// - Process images asynchronously for better performance
/// - Handle various image formats and edge cases
/// - Apply professional-quality background removal
///
/// - Face and body detection for validation
/// - High-quality person segmentation
/// - Automatic mask generation and application
/// - Performance optimized for real-time use
enum BackgroundRemover {
  // MARK: - Vision Requests Configuration

  /// Vision request for detecting faces in images
  /// Uses the latest revision for improved accuracy
  private static let faceDetectionRequest: VNDetectFaceRectanglesRequest = {
    let request = VNDetectFaceRectanglesRequest()
    request.revision = VNDetectFaceRectanglesRequestRevision3
    return request
  }()

  /// Vision request for detecting human bodies in images
  /// Optimized for full-body detection scenarios
  private static let bodyDetectionRequest: VNDetectHumanRectanglesRequest = {
    let request = VNDetectHumanRectanglesRequest()
    request.revision = VNDetectHumanRectanglesRequestRevision2
    return request
  }()

  /// Vision request for generating person segmentation masks
  /// Configured for highest quality output
  private static let personSegmentationRequest: VNGeneratePersonSegmentationRequest = {
    let request = VNGeneratePersonSegmentationRequest()
    request.qualityLevel = .accurate // Use highest quality setting
    request.outputPixelFormat = kCVPixelFormatType_OneComponent8
    request.revision = VNGeneratePersonSegmentationRequestRevision1
    return request
  }()

  // MARK: - Public Interface

  // swiftlint:disable:next orphaned_doc_comment
  /// Removes the background from an image using AI-powered person segmentation.
  ///
  /// This method performs the following steps:
  /// 1. Validates that a person is present in the image
  /// 2. Generates a high-quality segmentation mask
  /// 3. Applies the mask to create a transparent background
  /// 4. Returns the processed image with background removed
  ///
  /// - Parameter image: The input UIImage containing a person
  /// - Returns: A UIImage with transparent background, or nil if processing fails
  ///
  /// **Performance Note:** This operation is CPU/GPU intensive and should be called
  /// from a background queue to avoid blocking the main thread.
  ///
  /// **Example Usage:**
  /// ```swift
  /// let processedImage = await BackgroundRemover.removeBackground(from: originalImage)
  /// ```
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

        debugPrint("✅ Successfully generated person mask")

        // Step 2: Apply mask to remove background
        guard let resultCIImage = applyTransparencyMask(maskImage, to: ciImage) else {
          debugPrint("❌ Failed to apply transparency mask")
          continuation.resume(returning: nil)
          return
        }

        debugPrint("✅ Successfully applied transparency mask")

        // Step 3: Convert result back to UIImage
        guard let resultUIImage = convertToUIImage(resultCIImage) else {
          debugPrint("❌ Failed to convert result to UIImage")
          continuation.resume(returning: nil)
          return
        }

        debugPrint("✅ Background removal completed successfully")
        continuation.resume(returning: resultUIImage)
      }
    }
  }

  // highlight-remove-background

  /// Checks if background removal is possible for the given image.
  ///
  /// This method performs a quick validation to determine if the image
  /// contains a detectable person before attempting full background removal.
  /// Use this method to provide user feedback or disable UI elements when
  /// background removal isn't possible.
  ///
  /// - Parameter image: The input UIImage to analyze
  /// - Returns: `true` if a person is detected and background removal is possible
  ///
  /// **Example Usage:**
  /// ```swift
  /// let canProcess = await BackgroundRemover.canRemoveBackground(from: image)
  /// if canProcess {
  ///     // Enable background removal button
  /// } else {
  ///     // Show "No person detected" message
  /// }
  /// ```
  static func canRemoveBackground(from image: UIImage) async -> Bool {
    guard let ciImage = CIImage(image: image) else {
      return false
    }

    return await withCheckedContinuation { continuation in
      Task {
        let personDetected = await detectPerson(in: ciImage)
        continuation.resume(returning: personDetected)
      }
    }
  }

  // MARK: - Private Implementation

  // swiftlint:disable:next orphaned_doc_comment
  /// Generates a person segmentation mask from the input image.
  ///
  /// This method combines person detection and segmentation to create
  /// a high-quality mask that identifies all pixels belonging to people.
  ///
  /// - Parameter image: The CIImage to process
  /// - Returns: A CIImage mask where white pixels represent the person
  // highlight-generate-mask
  private static func generatePersonMask(from image: CIImage) async -> CIImage? {
    await withCheckedContinuation { continuation in
      // Use a high-priority background queue for Vision processing
      DispatchQueue.global(qos: .userInitiated).async {
        let requestHandler = VNSequenceRequestHandler()

        do {
          // Perform all Vision requests simultaneously for efficiency
          try requestHandler.perform([
            faceDetectionRequest,
            bodyDetectionRequest,
            personSegmentationRequest,
          ], on: image)

          // Validate that a person was detected
          let faces = faceDetectionRequest.results ?? []
          let bodies = bodyDetectionRequest.results ?? []

          guard !faces.isEmpty || !bodies.isEmpty else {
            debugPrint("⚠️ No person detected in image")
            continuation.resume(returning: nil)
            return
          }

          debugPrint("✅ Person detected - Faces: \(faces.count), Bodies: \(bodies.count)")

          // Extract the segmentation mask
          guard let maskPixelBuffer = personSegmentationRequest.results?.first?.pixelBuffer else {
            debugPrint("❌ Person segmentation failed")
            continuation.resume(returning: nil)
            return
          }

          // Convert pixel buffer to CIImage
          var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

          // Scale mask to match input image dimensions
          let scaleTransform = calculateScaleTransform(
            from: maskImage.extent.size,
            to: image.extent.size,
          )
          maskImage = maskImage.transformed(by: scaleTransform)

          debugPrint("✅ Mask generated and scaled successfully")
          continuation.resume(returning: maskImage)

        } catch {
          debugPrint("❌ Vision processing failed: \(error.localizedDescription)")
          continuation.resume(returning: nil)
        }
      }
    }
  }

  // highlight-generate-mask

  /// Detects if a person is present in the image without generating a full mask.
  ///
  /// This is a lightweight operation used for quick validation.
  ///
  /// - Parameter image: The CIImage to analyze
  /// - Returns: `true` if a person is detected
  private static func detectPerson(in image: CIImage) async -> Bool {
    await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        let requestHandler = VNSequenceRequestHandler()

        do {
          // Only perform detection requests (faster than segmentation)
          try requestHandler.perform([
            faceDetectionRequest,
            bodyDetectionRequest,
          ], on: image)

          let faces = faceDetectionRequest.results ?? []
          let bodies = bodyDetectionRequest.results ?? []
          let personDetected = !faces.isEmpty || !bodies.isEmpty

          debugPrint("🔍 Person detection result: \(personDetected)")
          continuation.resume(returning: personDetected)

        } catch {
          debugPrint("❌ Person detection failed: \(error.localizedDescription)")
          continuation.resume(returning: false)
        }
      }
    }
  }

  // swiftlint:disable:next orphaned_doc_comment
  /// Applies a transparency mask to create a background-removed image.
  ///
  /// This method uses Core Image filters to composite the original image
  /// with a transparent background using the person mask.
  ///
  /// - Parameters:
  ///   - mask: The segmentation mask (white = keep, black = remove)
  ///   - image: The original image
  /// - Returns: The composited image with transparent background
  // highlight-apply-mask
  private static func applyTransparencyMask(_ mask: CIImage, to image: CIImage) -> CIImage? {
    // Use CIBlendWithRedMask for high-quality masking
    guard let blendFilter = CIFilter(name: "CIBlendWithRedMask") else {
      debugPrint("❌ CIBlendWithRedMask filter not available")
      return nil
    }

    // Configure the blend filter
    blendFilter.setDefaults()
    blendFilter.setValue(image, forKey: kCIInputImageKey)

    // Create a fully transparent background
    let transparentBackground = CIImage(color: CIColor.clear).cropped(to: image.extent)
    blendFilter.setValue(transparentBackground, forKey: kCIInputBackgroundImageKey)
    blendFilter.setValue(mask, forKey: kCIInputMaskImageKey)

    guard let outputImage = blendFilter.outputImage else {
      debugPrint("❌ Failed to generate blended output")
      return nil
    }

    return outputImage
  }

  // highlight-apply-mask

  /// Converts a CIImage to UIImage with proper handling of color spaces and orientation.
  ///
  /// - Parameter ciImage: The CIImage to convert
  /// - Returns: The converted UIImage, or nil if conversion fails
  private static func convertToUIImage(_ ciImage: CIImage) -> UIImage? {
    // Use a high-performance CIContext for rendering
    let context = CIContext(options: [
      .useSoftwareRenderer: false, // Prefer GPU rendering
      .highQualityDownsample: true,
    ])

    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
      debugPrint("❌ Failed to create CGImage from CIImage")
      return nil
    }

    return UIImage(cgImage: cgImage)
  }

  /// Calculates the transform needed to scale one size to match another.
  ///
  /// - Parameters:
  ///   - fromSize: The source size
  ///   - toSize: The target size
  /// - Returns: A CGAffineTransform for scaling
  private static func calculateScaleTransform(from fromSize: CGSize, to toSize: CGSize) -> CGAffineTransform {
    let scaleX = toSize.width / fromSize.width
    let scaleY = toSize.height / fromSize.height

    debugPrint("📐 Scaling mask from \(fromSize) to \(toSize) (scaleX: \(scaleX), scaleY: \(scaleY))")

    return CGAffineTransform(scaleX: scaleX, y: scaleY)
  }
}

// MARK: - Debug Utilities

/// Enhanced debug printing that only outputs in debug builds
private func debugPrint(_ message: String) {
  #if DEBUG
    print("[BackgroundRemover] \(message)")
  #endif
}
