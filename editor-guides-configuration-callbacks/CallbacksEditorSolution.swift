// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
// highlight-import
import IMGLYEditor
import IMGLYEngine

// highlight-import
import SwiftUI

private enum CallbackError: Error {
  case noScene
  case noPage
  case couldNotExport
}

struct CallbacksEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          // highlight-onCreate
          builder.onCreate { engine, _ in
            // Load or create scene
            let sceneURL = Bundle.main.url(forResource: "design-ui-empty", withExtension: "scene")!
            try await engine.scene.load(from: sceneURL) // or `engine.scene.create*`
            // Add asset sources
            let basePath = try engine.editor.getSettingString("basePath")
            guard let baseURL = URL(string: basePath) else { return }
            let sourceIDs = [
              "ly.img.sticker", "ly.img.vector.shape", "ly.img.filter", "ly.img.color.palette",
              "ly.img.effect", "ly.img.blur", "ly.img.typeface", "ly.img.crop.presets",
              "ly.img.page.presets", "ly.img.text", "ly.img.text.components",
              "ly.img.caption.presets", "ly.img.image",
            ]
            try await withThrowingTaskGroup(of: String.self) { group in
              for id in sourceIDs {
                group.addTask {
                  try await engine.asset.addLocalAssetSourceFromJSON(
                    baseURL.appendingPathComponent(id).appendingPathComponent("content.json"),
                  )
                }
              }
              for try await _ in group {}
            }
            try engine.asset.addLocalSource(
              sourceID: "ly.img.image.upload",
              supportedMimeTypes: ["image/jpeg", "image/png", "image/svg+xml", "image/gif", "image/apng", "image/bmp"],
            )
            try await engine.asset.addSource(TextAssetSource(engine: engine))
            try engine.asset.addSource(PhotoRollAssetSource(engine: engine))
          }
          // highlight-onCreate
          // highlight-onExport
          builder.onExport { mainEngine, eventHandler, _ in
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
              eventHandler.send(.exportProgress(.relative(.zero)))
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

            // Export the design scene
            let (data, mimeType) = try await export()

            // Write and share file
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(
              "Export",
              conformingTo: mimeType.uniformType,
            )
            try data.write(to: url, options: [.atomic])
            eventHandler.send(.shareFile(url))
          }
          // highlight-onExport
          // highlight-onUpload
          builder.onUpload { engine, sourceID, asset, _ in
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
          // highlight-onClose
          builder.onClose { engine, eventHandler, _ in
            let hasUnsavedChanges = (try? engine.editor.canUndo()) ?? false

            if hasUnsavedChanges {
              eventHandler.send(.showCloseConfirmationAlert)
            } else {
              eventHandler.send(.closeEditor)
            }
          }
          // highlight-onClose
          // highlight-onError
          builder.onError { error, eventHandler, _ in
            eventHandler.send(.showErrorAlert(error))
          }
          // highlight-onError
          // highlight-onLoaded
          builder.onLoaded { context, _ in
            // Example: Open the elements library sheet after the editor loaded as `Dock.Buttons.elementsLibrary()` would do.
            context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.elementsTab }))
          }
          // highlight-onLoaded
        }
      }
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

#Preview {
  CallbacksEditorSolution()
}
