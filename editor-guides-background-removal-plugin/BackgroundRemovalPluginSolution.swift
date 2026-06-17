// highlight-bgRemovalPlugin-imports
import IMGLYEditor
import IMGLYEngine
import IMGLYPluginBackgroundRemoval

// highlight-bgRemovalPlugin-imports
import SwiftUI

struct BackgroundRemovalPluginSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            let baseURL = secrets.baseURL
              ?? URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.77.0-rc.2/assets")!
            let imageURL = baseURL.appendingPathComponent("ly.img.image/images/sample_14.jpg")
            try await engine.scene.create(fromImage: imageURL)
          }
        }
        BackgroundRemovalPlugin()
      }
  }

  // The lesson code shown in the documentation. The runtime demo above wraps
  // this in `onCreate` so the showcase has an image to operate on; the rendered
  // snippet keeps the minimal integration developers add to their own editor.
  @ViewBuilder var editor: some View {
    // highlight-bgRemovalPlugin-basicSetup
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
        BackgroundRemovalPlugin()
      }
    // highlight-bgRemovalPlugin-basicSetup
  }
}

// MARK: - Error Handling

struct BackgroundRemovalErrorHandlingSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")
  @State private var errorMessage: String?

  var body: some View {
    // highlight-bgRemovalPlugin-errorHandling
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
        BackgroundRemovalPlugin(onError: { error in
          errorMessage = error.localizedDescription
        })
      }
      .alert("Background Removal Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "")
      }
    // highlight-bgRemovalPlugin-errorHandling
  }
}

// MARK: - Apple Vision Backend

struct BackgroundRemovalVisionSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-bgRemovalPlugin-visionBackend
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
        BackgroundRemovalPlugin(configuration: VisionBackgroundRemovalConfiguration())
      }
    // highlight-bgRemovalPlugin-visionBackend
  }
}

// MARK: - IMG.LY Backend Tuning

struct BackgroundRemovalIMGLYTuningSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-bgRemovalPlugin-imglyTuning
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
        BackgroundRemovalPlugin(
          configuration: IMGLYBackgroundRemovalConfiguration(
            model: .fp32,
            modelBaseURL: IMGLYBackgroundRemovalConfiguration.defaultModelBaseURL,
            loadMode: .lazy,
          ),
        )
      }
    // highlight-bgRemovalPlugin-imglyTuning
  }
}

// MARK: - Button Placement

struct BackgroundRemovalPlacementSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-bgRemovalPlugin-buttonPlacement
    Editor(settings)
      .imgly.configuration {
        PhotoEditorConfiguration()
        BackgroundRemovalPlugin(
          dockModifier: { items, button in
            items.addLast { button }
          },
        )
      }
    // highlight-bgRemovalPlugin-buttonPlacement
  }
}
