import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Showcase

struct CustomFeaturePluginSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>",
                                baseURL: secrets.baseURL)

  static let imageURL = URL(string: "https://img.ly/static/ubq_samples/sample_1.jpg")!

  var body: some View {
    // highlight-customPlugin-applyPlugin
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        CustomFeaturePlugin(options: .init(imageURL: Self.imageURL))
      }
    // highlight-customPlugin-applyPlugin
  }
}

// MARK: - Plugin

@MainActor
final class CustomFeaturePlugin: EditorConfiguration {
  // highlight-customPlugin-optionsStruct
  struct Options {
    var imageURL: URL
  }

  // highlight-customPlugin-optionsStruct

  private let options: Options

  init(options: Options) {
    self.options = options
    super.init()
  }

  // MARK: - Callbacks

  // highlight-customPlugin-onCreate
  override var onCreate: OnCreate.Handler? {
    { _, existing in
      // Pre-setup work goes here.
      try await existing()
      // Post-setup work goes here.
    }
  }

  // highlight-customPlugin-onCreate

  // highlight-customPlugin-onExport
  override var onExport: OnExport.Handler? {
    { engine, eventHandler, _ in
      let archive = try await engine.scene.saveToArchive()
      let url = try Self.writeArchiveToTempFile(archive)
      eventHandler.send(.shareFile(url))
    }
  }

  // highlight-customPlugin-onExport

  // MARK: - Components

  // highlight-customPlugin-dock
  override var dock: Dock.Configuration? {
    let imageURL = options.imageURL
    return Dock.Configuration { builder in
      builder.modify { _, items in
        items.addFirst {
          Dock.Button(
            id: "com.example.dock.customFeature",
            action: { context in
              Task { try? await Self.addImageBlock(engine: context.engine, imageURL: imageURL) }
            },
            label: { _ in
              Label {
                Text("Image")
              } icon: {
                Image(systemName: "photo")
              }
            },
          )
        }
      }
    }
  }

  // highlight-customPlugin-dock

  // highlight-customPlugin-canvasMenu
  override var canvasMenu: CanvasMenu.Configuration? {
    CanvasMenu.Configuration { builder in
      builder.items { _ in }
    }
  }

  // highlight-customPlugin-canvasMenu

  // MARK: - Helpers

  // highlight-customPlugin-addImage
  private static func addImageBlock(engine: Engine, imageURL: URL) async throws {
    guard let page = try engine.scene.getCurrentPage() else { return }
    let block = try engine.block.create(.graphic)
    let shape = try engine.block.createShape(.rect)
    let fill = try engine.block.createFill(.image)
    try engine.block.setShape(block, shape: shape)
    try engine.block.setURL(fill, property: "fill/image/imageFileURI", value: imageURL)
    try engine.block.setFill(block, fill: fill)
    try engine.block.setContentFillMode(block, mode: .cover)
    try engine.block.setWidthMode(block, mode: .percent)
    try engine.block.setWidth(block, value: 0.5)
    try engine.block.appendChild(to: page, child: block)
    if try engine.block.isAlignable([block]) {
      try engine.block.alignHorizontally([block], alignment: .center)
      try engine.block.alignVertically([block], alignment: .center)
    }
    try engine.block.setSelected(block, selected: true)
    try engine.editor.addUndoStep()
  }

  // highlight-customPlugin-addImage

  // highlight-customPlugin-writeArchive
  private static func writeArchiveToTempFile(_ archive: Blob) throws -> URL {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("custom-feature-\(UUID().uuidString)")
      .appendingPathExtension("scene.zip")
    try archive.write(to: url, options: [.atomic])
    return url
  }
  // highlight-customPlugin-writeArchive
}

#Preview {
  CustomFeaturePluginSolution()
}
