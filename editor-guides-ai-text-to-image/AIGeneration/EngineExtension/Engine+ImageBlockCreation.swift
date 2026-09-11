import Foundation
import IMGLYEngine

// MARK: - Engine Helpers for AI Image Generation

extension Engine {
  // MARK: - Block Creation

  /// Creates a new image block with loading state, sized to fit the page
  func createImageBlock(size: ImageSize) throws -> DesignBlockID {
    guard let page = try scene.getCurrentPage() else {
      throw ImageBlockError.noCurrentPage
    }

    let newBlock = try block.create(.graphic)

    let shape = try block.createShape(.rect)
    try block.setShape(newBlock, shape: shape)

    let imageFill = try block.createFill(.image)
    try block.setFill(newBlock, fill: imageFill)

    let dimensions = try canvasAwareDimensions(for: size, on: page)
    try block.setWidth(newBlock, value: dimensions.width)
    try block.setHeight(newBlock, value: dimensions.height)

    try block.appendChild(to: page, child: newBlock)
    try centerBlock(newBlock, on: page)
    try block.setState(newBlock, state: .pending(progress: 0))

    return newBlock
  }

  // MARK: - Block Updates

  /// Updates an existing block with a remote URL
  func updateBlockWithURL(_ blockID: DesignBlockID, imageURL: URL) throws {
    let imageFill = try block.getFill(blockID)

    try block.setString(imageFill, property: "fill/image/imageFileURI", value: imageURL.absoluteString)
    try block.setState(blockID, state: .ready)
  }

  // MARK: - Canvas Helpers

  /// Calculate dimensions that fit within 80% of the page bounds
  func canvasAwareDimensions(
    for size: ImageSize,
    on page: DesignBlockID,
  ) throws -> (width: Float, height: Float) {
    let dims = size.dimensions
    let w = Float(max(dims.width, 1))
    let h = Float(max(dims.height, 1))

    let maxW = try block.getWidth(page) * 0.8
    let maxH = try block.getHeight(page) * 0.8
    let scale = min(maxW / w, maxH / h)

    return (w * scale, h * scale)
  }

  /// Center a block on the page
  func centerBlock(_ target: DesignBlockID, on page: DesignBlockID) throws {
    let pageW = try block.getWidth(page)
    let pageH = try block.getHeight(page)
    let blockW = try block.getWidth(target)
    let blockH = try block.getHeight(target)

    try block.setPositionX(target, value: (pageW - blockW) / 2)
    try block.setPositionY(target, value: (pageH - blockH) / 2)
  }
}

// MARK: - Supporting Types

enum ImageBlockError: LocalizedError {
  case noCurrentPage

  var errorDescription: String? {
    switch self {
    case .noCurrentPage:
      "No current page found in the editor"
    }
  }
}
