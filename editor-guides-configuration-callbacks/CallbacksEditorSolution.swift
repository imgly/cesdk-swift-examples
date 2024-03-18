// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
// highlight-import
import IMGLYDesignEditor
import IMGLYEngine
// highlight-import
import SwiftUI

private enum CallbackError: Error {
  case unknownSceneMode
  case noScene
  case noPage
  case couldNotExport
}

struct CallbacksEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-onCreate
      .imgly.onCreate { engine in
        // Load or create scene
        try await engine.scene.load(from: DesignEditor.defaultScene) // or `engine.scene.create*`
        // Add asset sources
        try await engine.addDefaultAssetSources(baseURL: Engine.assetBaseURL)
        try await engine.addDemoAssetSources(sceneMode: engine.scene.getMode(),
                                             withUploadAssetSources: true)
        try engine.asset.addSource(TextAssetSource(engine: engine))
      }
      // highlight-onCreate
      // highlight-onExport
      .imgly.onExport { mainEngine, eventHandler in
        // Export design scene
        @MainActor func export() async throws -> (Data, MIMEType) {
          guard let scene = try mainEngine.scene.get() else {
            throw CallbackError.noScene
          }
          let mimeType: MIMEType = .pdf
          let data = try await mainEngine.block.export(scene, mimeType: mimeType) { backgroundEngine in
            // Modify state of the background engine for export without affecting
            // the main engine that renders the preview on the canvas
            try backgroundEngine.scene.getPages().forEach {
              try backgroundEngine.block.setScopeEnabled($0, key: "layer/visibility", enabled: true)
              try backgroundEngine.block.setVisible($0, visible: true)
            }
          }
          return (data, mimeType)
        }

        // Export video scene
        @MainActor func exportVideo() async throws -> (Data, MIMEType) {
          guard let page = try mainEngine.scene.getCurrentPage() else {
            throw CallbackError.noPage
          }
          eventHandler.send(.exportProgress(.relative(0)))
          let mimeType: MIMEType = .mp4
          let stream = try await mainEngine.block.exportVideo(page, mimeType: mimeType) { backgroundEngine in
            // Modify state of the background engine for export without affecting
            // the main engine that renders the preview on the canvas
          }
          for try await export in stream {
            try Task.checkCancellation()
            switch export {
            case let .progress(_, encodedFrames, totalFrames):
              let percentage = Float(encodedFrames) / Float(totalFrames)
              eventHandler.send(.exportProgress(.relative(percentage)))
            case let .finished(video: videoData):
              return (videoData, mimeType)
            }
          }
          try Task.checkCancellation()
          throw CallbackError.couldNotExport
        }

        // Export scene based on `SceneMode`
        let data: Data, mimeType: MIMEType
        switch try mainEngine.scene.getMode() {
        case .design: (data, mimeType) = try await export()
        case .video: (data, mimeType) = try await exportVideo()
        @unknown default:
          throw CallbackError.unknownSceneMode
        }

        // Write and share file
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
          "Export",
          conformingTo: mimeType.uniformType
        )
        try data.write(to: url, options: [.atomic])
        eventHandler.send(.shareFile(url))
      }
      // highlight-onExport
      // highlight-onUpload
      .imgly.onUpload { engine, sourceID, asset in
        var newMeta = asset.meta ?? [:]
        for (key, value) in newMeta {
          switch key {
          case "uri", "thumbUri":
            if let sourceURL = URL(string: value) {
              let uploadedURL = sourceURL // Upload the asset here and return remote URL
              newMeta[key] = uploadedURL.absoluteString
            }
          default:
            break
          }
        }
        return .init(id: asset.id, groups: asset.groups, meta: newMeta, label: asset.label, tags: asset.tags)
      }
    // highlight-onUpload
  }

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
}
