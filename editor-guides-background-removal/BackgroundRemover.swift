@preconcurrency import CoreImage
import Foundation
import ImageIO
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
  // MARK: - Configuration

  /// Maximum pixel dimension for Vision processing.
  /// Only the segmentation step is downsampled; the final output preserves the original resolution.
  private static let maxVisionDimension: CGFloat = 3072

  /// Shared CIContext for rendering, avoids repeated allocation.
  private static let ciContext = CIContext(options: [
    .useSoftwareRenderer: false,
    .highQualityDownsample: true,
  ])

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
  /// Configured for balanced quality and memory usage
  private static let personSegmentationRequest: VNGeneratePersonSegmentationRequest = {
    let request = VNGeneratePersonSegmentationRequest()
    request.qualityLevel = .balanced
    request.outputPixelFormat = kCVPixelFormatType_OneComponent8
    request.revision = VNGeneratePersonSegmentationRequestRevision1
    return request
  }()

  // MARK: - Public Interface

  // swiftlint:disable:next orphaned_doc_comment
  /// Removes the background from an image and writes the result directly to a file.
  ///
  /// This method works entirely with lazy `CIImage` operations and writes the final
  /// PNG to disk via `CIContext.writePNGRepresentation`, so only **one** full-resolution
  /// pixel buffer is ever materialised. Vision processing is performed on a downsampled
  /// copy to stay within device memory limits, but the mask is scaled back up and applied
  /// to the original image — the output preserves the full input resolution.
  ///
  /// - Parameter imageData: The compressed image file data (JPEG, PNG, HEIC, …).
  /// - Returns: A file `URL` to the resulting PNG with a transparent background,
  ///   or `nil` if processing fails.
  // highlight-remove-background
  static func removeBackground(from imageData: Data) async -> URL? {
    // CIImage(data:) is lazy — the full pixel buffer is NOT decompressed here.
    guard let ciImage = CIImage(data: imageData) else {
      debugPrint("❌ Failed to create CIImage from data")
      return nil
    }

    // Apply EXIF orientation so the image is upright for Vision.
    let orientation = ciImage.properties[kCGImagePropertyOrientation as String] as? UInt32 ?? 1
    let orientedImage = ciImage.oriented(.init(rawValue: orientation) ?? .up)

    // Downsample for Vision only — the final output stays at original resolution.
    let visionImage = downsampleIfNeeded(orientedImage)

    return await withCheckedContinuation { continuation in
      Task {
        // Step 1: Generate person segmentation mask at reduced resolution
        guard let maskImage = await generatePersonMask(from: visionImage) else {
          debugPrint("❌ Failed to generate person mask")
          continuation.resume(returning: nil)
          return
        }

        debugPrint("✅ Successfully generated person mask")

        // Step 2: Scale mask to original image size (lazy — no memory allocated)
        let fullResMask = maskImage.transformed(by: calculateScaleTransform(
          from: maskImage.extent.size,
          to: orientedImage.extent.size,
        ))

        // Step 3: Apply mask to original full-resolution image (lazy — no memory allocated)
        guard let resultCIImage = applyTransparencyMask(fullResMask, to: orientedImage) else {
          debugPrint("❌ Failed to apply transparency mask")
          continuation.resume(returning: nil)
          return
        }

        debugPrint("✅ Successfully applied transparency mask")

        // Step 4: Write result directly to a file — only ONE full-res buffer is rendered.
        guard let outputURL = writeToCache(resultCIImage) else {
          debugPrint("❌ Failed to write result to cache")
          continuation.resume(returning: nil)
          return
        }

        debugPrint("✅ Background removal completed successfully")
        continuation.resume(returning: outputURL)
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

          // Convert pixel buffer to CIImage (raw mask size, scaling is handled by the caller)
          let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

          debugPrint("✅ Mask generated successfully")
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

  /// Writes a CIImage directly to a PNG file in the caches directory.
  ///
  /// Using `writePNGRepresentation` instead of `createCGImage` + `pngData()` avoids
  /// keeping an extra full-resolution CGImage / UIImage in memory.
  private static func writeToCache(_ ciImage: CIImage) -> URL? {
    do {
      let cacheURL = try FileManager.default
        .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(UUID().uuidString, conformingTo: .png)

      let colorSpace = ciImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
      try ciContext.writePNGRepresentation(of: ciImage, to: cacheURL, format: .RGBA8, colorSpace: colorSpace)
      return cacheURL
    } catch {
      debugPrint("❌ Failed to write PNG: \(error.localizedDescription)")
      return nil
    }
  }

  /// Downsamples a CIImage if its largest dimension exceeds ``maxVisionDimension``.
  private static func downsampleIfNeeded(_ image: CIImage) -> CIImage {
    let maxDim = max(image.extent.width, image.extent.height)
    guard maxDim > maxVisionDimension else { return image }

    let scale = maxVisionDimension / maxDim
    debugPrint("📐 Downsampling from \(image.extent.size) by factor \(scale)")
    return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
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
