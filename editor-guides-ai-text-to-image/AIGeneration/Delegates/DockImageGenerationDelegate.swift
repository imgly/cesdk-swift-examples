import IMGLYDesignEditor
import IMGLYEngine

/// Delegate for generating new images from the dock context.
/// Creates new image blocks on the canvas.
@MainActor
final class DockImageGenerationDelegate: ImageGenerationDelegate {
  private let aiService: any AIImageService
  private let engine: Engine?
  /// Used to show the editor's native error alert on failure.
  /// Replace with your own error handling (e.g. custom toast, logging) as needed.
  private let eventHandler: EditorEventHandler?

  init(dockContext: Dock.Context?, aiService: any AIImageService) {
    self.aiService = aiService
    engine = dockContext?.engine
    eventHandler = dockContext?.eventHandler
  }

  func generateImage(with settings: GenerationSettings) async {
    guard let engine else { return }

    var loadingBlock: DesignBlockID?

    do {
      // 1. Create loading block on canvas
      let imageSize = ImageGenerationUtils.mapSettingsToImageSize(settings)
      loadingBlock = try engine.createImageBlock(size: imageSize)

      // 2. Generate image via AI service
      let request = ImageGenerationUtils.createRequest(from: settings)
      let result = try await aiService.generateImage(with: request)

      // 3. Update block with generated image URL
      guard let loadingBlock else {
        throw AIServiceError.generationFailed("Failed to create image block.")
      }
      try engine.updateBlockWithURL(loadingBlock, imageURL: result.imageURL)

    } catch {
      // Remove the pending block on failure
      if let loadingBlock {
        try? engine.block.destroy(loadingBlock)
      }
      eventHandler?.send(.showErrorAlert(error))
    }
  }
}
