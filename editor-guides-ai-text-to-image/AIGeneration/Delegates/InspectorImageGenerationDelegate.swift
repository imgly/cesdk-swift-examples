import Foundation
import IMGLYDesignEditor
import IMGLYEngine

/// Delegate for enhancing selected images from the inspector context.
/// Replaces the selected image with AI-generated variations.
@MainActor
public final class InspectorImageGenerationDelegate: ImageGenerationDelegate {
  private let aiService: any AIImageService
  private let engine: Engine
  private let selectedBlockID: DesignBlockID?
  /// Used to show the editor's native error alert on failure.
  /// Replace with your own error handling (e.g. custom toast, logging) as needed.
  private let eventHandler: EditorEventHandler

  public init(inspectorContext: InspectorBar.Context, aiService: any AIImageService) {
    self.aiService = aiService
    engine = inspectorContext.engine
    selectedBlockID = inspectorContext.selection.block
    eventHandler = inspectorContext.eventHandler
  }

  public func generateImage(with settings: GenerationSettings) async {
    guard let selectedBlock = selectedBlockID else { return }

    do {
      let fill = try engine.block.getFill(selectedBlock)

      try engine.block.setState(selectedBlock, state: .pending(progress: 0))

      // Prepare source image
      let currentImageURI = try engine.block.getString(fill, property: "fill/image/imageFileURI")
      let (sourceImageData, sourceURL) = try await prepareSourceImageData(from: currentImageURI)

      // Build request
      var modifiedSettings = settings
      modifiedSettings.mode = .imageToImage
      modifiedSettings.sourceImageData = sourceImageData
      modifiedSettings.sourceImageURL = sourceURL
      let request = ImageGenerationUtils.createRequest(from: modifiedSettings, includeSize: false)

      // Generate
      let result = try await aiService.generateImage(with: request)

      // Apply result
      try applyResult(result, to: selectedBlock, fill: fill, settings: modifiedSettings)

    } catch {
      if let selectedBlock = selectedBlockID {
        try? engine.block.setState(selectedBlock, state: .ready)
      }
      eventHandler.send(.showErrorAlert(error))
    }
  }

  // MARK: - Private

  private func prepareSourceImageData(from imageURI: String) async throws -> (data: Data?, url: String?) {
    guard let imageURL = URL(string: imageURI) else {
      throw AIServiceError.invalidRequest("Invalid image URI: \(imageURI)")
    }

    if let scheme = imageURL.scheme?.lowercased(), ["http", "https"].contains(scheme) {
      return (nil, imageURI)
    } else {
      let imageData = try Data(contentsOf: imageURL)
      if imageData.count > 5 * 1024 * 1024 {
        throw AIServiceError.invalidRequest("Image is too large. Please use an image under 5 MB.")
      }
      return (imageData, nil)
    }
  }

  private func applyResult(
    _ result: GeneratedImage,
    to block: DesignBlockID,
    fill: DesignBlockID,
    settings: GenerationSettings,
  ) throws {
    try engine.block.setString(fill, property: "fill/image/imageFileURI", value: result.imageURL.absoluteString)

    if settings.mode != .imageToImage, settings.format != .custom {
      try resizeBlock(block, settings: settings)
    }

    try engine.block.setState(block, state: .ready)
  }

  private func resizeBlock(_ block: DesignBlockID, settings: GenerationSettings) throws {
    guard let page = try engine.scene.getCurrentPage() else { return }

    let imageSize = ImageGenerationUtils.mapSettingsToImageSize(settings)
    let dimensions = try engine.canvasAwareDimensions(for: imageSize, on: page)

    try engine.block.setWidth(block, value: dimensions.width)
    try engine.block.setHeight(block, value: dimensions.height)
    try engine.centerBlock(block, on: page)
  }
}
