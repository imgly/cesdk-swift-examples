// highlight-bgRemovalPlugin-imports
import IMGLYEditor
import IMGLYEngine
import IMGLYPluginBackgroundRemoval

// highlight-bgRemovalPlugin-imports
import SwiftUI

struct BackgroundRemovalPluginSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>",
                                baseURL: secrets.baseURL)

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await DesignEditorConfiguration.defaultOnCreate(
              createScene: { engine in
                try await DesignEditorConfiguration.defaultCreateScene(engine)
                let basePath = try engine.editor.getSettingString("basePath")
                guard let page = try engine.scene.getPages().first,
                      let imageURL = URL(string: "\(basePath)/ly.img.image/images/sample_14.jpg") else { return }
                let colorFill = try engine.block.getFill(page)
                let imageFill = try engine.block.createFill(.image)
                try engine.block.setURL(imageFill, property: "fill/image/imageFileURI", value: imageURL)
                try engine.block.setFill(page, fill: imageFill)
                try engine.block.destroy(colorFill)
              },
            )(engine)
          }
        }
        BackgroundRemovalPlugin(inspectorBarModifier: { items, button in
          items.addFirst { button }
        })
      }
  }

  // The lesson code shown in the documentation. The runtime demo above wraps
  // this in `onCreate` so the showcase has an image to operate on, and adds the
  // inspector bar button for images on the page; the rendered snippet keeps the
  // minimal integration developers add to their own editor.
  var editor: some View {
    // highlight-bgRemovalPlugin-basicSetup
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
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
        DesignEditorConfiguration()
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
        DesignEditorConfiguration()
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
        DesignEditorConfiguration()
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
        DesignEditorConfiguration()
        BackgroundRemovalPlugin(
          dockModifier: { items, button in
            items.addLast { button }
          },
        )
      }
    // highlight-bgRemovalPlugin-buttonPlacement
  }
}

// MARK: - Inspector Bar Button Placement

struct BackgroundRemovalInspectorBarPlacementSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-bgRemovalPlugin-inspectorBarPlacement
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        BackgroundRemovalPlugin(
          inspectorBarModifier: { items, button in
            items.addLast { button }
          },
        )
      }
    // highlight-bgRemovalPlugin-inspectorBarPlacement
  }
}
