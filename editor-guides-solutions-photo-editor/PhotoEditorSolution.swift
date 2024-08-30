// highlight-import
import IMGLYEngine
import IMGLYPhotoEditor

// highlight-import
import SwiftUI

struct PhotoEditorSolution: View {
  // highlight-editor
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    PhotoEditor(settings)
      // highlight-editor
      // highlight-callbacks
      .imgly.onCreate { engine in
        // Create scene from image
        try await engine.scene.create(fromImage: Bundle.main.url(forResource: "sample_image", withExtension: "jpg")!)
        // Add asset sources
        try await engine.addDefaultAssetSources(baseURL: Engine.assetBaseURL)
        try await engine.addDemoAssetSources(sceneMode: engine.scene.getMode(),
                                             withUploadAssetSources: true)
        try await engine.asset.addSource(TextAssetSource(engine: engine))

        let page = try engine.scene.getPages().first!
        // Define custom page (photo) size if needed
        try engine.block.setWidth(page, value: 1080)
        try engine.block.setHeight(page, value: 1080)

        // Assign image fill to page
        let image = try engine.block.find(byType: .graphic).first!
        try engine.block.setFill(page, fill: engine.block.getFill(image))
        try engine.block.destroy(image)
      }
      .imgly.onExport { engine, eventHandler in
        // Export photo
        let scene = try engine.scene.get()!
        let mimeType: MIMEType = .jpeg
        let data = try await engine.block.export(scene, mimeType: mimeType)

        // Write and share file
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
          "Export",
          conformingTo: mimeType.uniformType
        )
        try data.write(to: url, options: [.atomic])
        eventHandler.send(.shareFile(url))
      }
    // highlight-callbacks
  }

  // highlight-modal
  @State private var isPresented = false

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
  // highlight-modal
}
