import IMGLYEngine
import IMGLYPhotoEditor
import SwiftUI

/// Photo Editor with AI-powered background removal capabilities.
///
/// This view demonstrates how to:
/// - Initialize the IMG.LY Photo Editor with an image URL
/// - Add custom functionality (background removal) to the editor toolbar
/// - Handle background removal processing and apply the result back to the PhotoEditor
struct BackgroundRemovalEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  // MARK: - Properties

  /// The URL of the image to be edited
  let url: URL

  // MARK: - State Properties

  /// Tracks if background removal is currently in progress
  @State private var isProcessingBackgroundRemoval = false

  /// Stores any processing errors to display to the user
  @State private var processingError: BackgroundRemovalError?

  // MARK: - Body

  var body: some View {
    PhotoEditor(settings)
      // Here we initialize the editor with the provided image
      .imgly.onCreate { engine in
        // Load the selected image into the editor
        try await OnCreate.loadImage(from: url)(engine)
      }
      // highlight-modify-dock-items
      // 'modifyDockItems' allows you to change the dock buttons, in this case I am just adding an extra button to the
      // default ones
      .imgly.modifyDockItems { context, items in
        // Add custom background removal button to the editor dock at the last position of the default ones
        items.addFirst {
          backgroundRemovalButton(context: context)
        }
      }
      // highlight-modify-dock-items
      .alert("Background Removal Error", isPresented: .constant(processingError != nil)) {
        Button("OK") {
          processingError = nil
        }
      } message: {
        Text(processingError?.localizedDescription ?? "An unexpected error occurred")
      }
  }

  // MARK: - UI Components

  // highlight-dock-button
  private func backgroundRemovalButton(context: Dock.Context) -> some Dock.Item {
    Dock.Button(
      id: "ly.img.backgroundRemoval",
      action: { context in
        Task {
          await performBackgroundRemoval(context: context)
        }
      },
      label: { _ in
        Label {
          Text("BG Removal")
        } icon: {
          Image("custom.person.and.background.dotted.badge.minus")
            .resizable()
            .scaledToFit()
        }
      },
    )
  }

  // highlight-dock-button

  // MARK: - Background Removal Logic

  /// Performs AI-powered background removal on the current image
  /// - Parameter context: The dock context containing the engine instance
  private func performBackgroundRemoval(context: Dock.Context) async {
    do {
      // Prevent multiple simultaneous operations
      guard !isProcessingBackgroundRemoval else { return }
      isProcessingBackgroundRemoval = true
      defer { isProcessingBackgroundRemoval = false }

      let engine = context.engine

      // highlight-extract-image
      // Get the current page (canvas) from the scene
      guard let currentPage = try engine.scene.getCurrentPage() else {
        throw BackgroundRemovalError.noPageFound
      }

      // Validate that the page contains an image
      let imageFill = try engine.block.getFill(currentPage)
      let fillType = try engine.block.getType(imageFill)
      guard fillType == FillType.image.rawValue else {
        throw BackgroundRemovalError.noImageFound(currentType: fillType)
      }

      // Set block into loading state
      try engine.block.setState(imageFill, state: .pending(progress: 0.5))

      // Step 1: Extract image data from block
      let imageData = try await extractImageData(from: imageFill, engine: engine)
      // highlight-extract-image

      // highlight-process-image
      // Step 2: Apply background removal — works directly on the compressed data so the
      // full-resolution pixel buffer is never held in memory as a UIImage.
      // The result is written to a PNG file; the output preserves the original resolution.
      guard let processedImageURL = await BackgroundRemover.removeBackground(from: imageData) else {
        try engine.block.setState(imageFill, state: .ready)
        throw BackgroundRemovalError.backgroundRemovalFailed
      }
      // highlight-process-image

      // highlight-replace-image
      // Step 3: Replace the original image with the new one without background
      try await engine.block.addImageFileURIToSourceSet(
        imageFill,
        property: "fill/image/sourceSet",
        uri: processedImageURL,
      )

      // Step 4: Add undo step so users can revert to the original image
      try engine.editor.addUndoStep()

      // Set block into ready state again
      try engine.block.setState(imageFill, state: .ready)
      // highlight-replace-image

    } catch {
      // Handle any errors that occurred during processing
      if let backgroundRemovalError = error as? BackgroundRemovalError {
        processingError = backgroundRemovalError
      } else {
        processingError = .unexpectedError(error)
      }
      print("Background removal failed: \(error.localizedDescription)")
    }
  }

  /// Extracts image data from a design block
  private func extractImageData(from block: DesignBlockID, engine: Engine) async throws -> Data {
    // I could also use here to check if the block is using a sourceSet
    let imageFileURI = try engine.block.getString(block, property: "fill/image/imageFileURI")
    guard let url = URL(string: imageFileURI) else {
      throw BackgroundRemovalError.noImageSourceFound
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    return data
  }
}

// MARK: - Error Handling

enum BackgroundRemovalError: LocalizedError {
  case noPageFound
  case noImageFound(currentType: String)
  case noImageSourceFound
  case backgroundRemovalFailed
  case unexpectedError(Error)

  var errorDescription: String? {
    switch self {
    case .noPageFound:
      "No active page found in the editor."

    case let .noImageFound(currentType):
      "The current page doesn't contain an image. Current content type: \(currentType)"

    case .noImageSourceFound:
      "No image source found for background removal."

    case .backgroundRemovalFailed:
      "AI background removal failed. Please ensure the image contains a clearly visible person."

    case let .unexpectedError(error):
      "Unexpected error: \(error.localizedDescription)"
    }
  }
}
