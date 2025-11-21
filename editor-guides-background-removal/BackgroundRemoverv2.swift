import CoreImage.CIFilterBuiltins
import UIKit
import Vision

/// A helper struct providing one static method for background removal.
/// This version uses the Vision framework's new
/// `VNGenerateForegroundInstanceMaskRequest` (iOS 17+)
/// for general-purpose subject segmentation.
@available(iOS 17.0, *)
struct BackgroundRemoverV2 {
  /// Removes the background from a given UIImage using Vision.
  ///
  /// - Parameter uiImage: The source image to process.
  /// - Returns: A new UIImage with the detected foreground preserved
  ///   and the background made transparent, or `nil` if the operation fails.
  ///
  /// ### Implementation overview
  /// 1. Convert the UIImage to a Core Image (CIImage) for Vision and Core Image processing.
  /// 2. Run Vision’s `VNGenerateForegroundInstanceMaskRequest`
  ///    to produce an instance segmentation mask.
  /// 3. Merge all detected instances into a single grayscale alpha mask.
  /// 4. Composite the original image over a transparent background using that mask as alpha.
  ///
  @MainActor
  static func removeWithForegroundInstanceMask(from uiImage: UIImage) async -> UIImage? {
    // Convert the UIKit UIImage into a Core Image representation
    // which Vision and Core Image APIs operate on.
    guard let ciImage = CIImage(image: uiImage) else {
      print("❌ Failed to create CIImage from UIImage.")
      return nil
    }

    // 1️⃣ Create the Vision request that produces foreground instance masks.
    //    Each “instance” represents one segmented subject (e.g., person, pet, object).
    let request = VNGenerateForegroundInstanceMaskRequest()

    // 2️⃣ Create a Vision request handler that can process our image.
    //    VNImageRequestHandler wraps the input image and orchestrates the request execution.
    let handler = VNImageRequestHandler(ciImage: ciImage)

    do {
      // 3️⃣ Perform the Vision request synchronously.
      //    This will analyze the image and populate `request.results`.
      try handler.perform([request])

      // 4️⃣ Retrieve the segmentation results.
      //    We only handle the first result because each request can return multiple.
      guard let result = request.results?.first else {
        print("❌ No mask results returned by Vision.")
        return nil
      }

      // 5️⃣ Merge all detected instances into one combined alpha mask.
      //    This creates a single-channel image (grayscale) that encodes
      //    the combined “foreground subject” region.
      //
      //    You can also choose to keep only specific instances (e.g., top confidence).
      let mergedMask = try result.generateScaledMaskForImage(
        forInstances: result.allInstances, // all detected subjects
        from: handler, // reference to the original image handler
      )

      // 6️⃣ Convert the mask’s pixel buffer into a CIImage for compositing.
      let maskCIImage = CIImage(cvPixelBuffer: mergedMask)

      // 7️⃣ Blend the original image over a transparent background using the mask.
      //    This step is handled by a Core Image filter in `composite(ciImage:alphaMask:)`.
      return composite(ciImage: ciImage, alphaMask: maskCIImage)

    } catch {
      // If Vision throws an error (invalid image, unsupported format, etc.)
      print("❌ Vision background removal failed: \(error.localizedDescription)")
      return nil
    }
  }

  // MARK: - Core Image compositing

  /// Composites the original image over a transparent background,
  /// using the segmentation mask as the alpha channel.
  ///
  /// - Parameters:
  ///   - ciImage: The source image as a CIImage.
  ///   - alphaMask: The grayscale mask from Vision,
  ///                where white = subject (fully visible) and black = background (transparent).
  /// - Returns: A UIImage with the background removed.
  @MainActor
  private static func composite(ciImage: CIImage, alphaMask: CIImage) -> UIImage? {
    // Vision's mask output might not match the original image size.
    // Here, we scale it to align perfectly with the input image dimensions.
    let scaleX = ciImage.extent.width / alphaMask.extent.width
    let scaleY = ciImage.extent.height / alphaMask.extent.height
    let resizedMask = alphaMask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

    // Core Image needs a rendering context for filter operations.
    // The CIContext can reuse GPU/CPU resources for faster repeated processing.
    let context = CIContext()

    // 1️⃣ Create a Core Image filter to composite the subject over transparency.
    //    `CIBlendWithMask` takes three images:
    //    - inputImage: the content we want to keep (our photo)
    //    - backgroundImage: what’s behind it (transparent color)
    //    - maskImage: controls per-pixel opacity (white=opaque, black=transparent)
    let filter = CIFilter.blendWithMask()

    // Provide the three required inputs.
    filter.inputImage = ciImage
    filter.backgroundImage = CIImage(color: .clear).cropped(to: ciImage.extent)
    filter.maskImage = resizedMask

    // 2️⃣ Render the filtered output into a new CGImage.
    guard
      let output = filter.outputImage,
      let cg = context.createCGImage(output, from: output.extent)
    else {
      print("❌ Failed to create CGImage from composited output.")
      return nil
    }

    // 3️⃣ Convert the rendered CGImage back into a UIImage
    //     that can be displayed or saved in UIKit-based workflows.
    return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
  }
}
