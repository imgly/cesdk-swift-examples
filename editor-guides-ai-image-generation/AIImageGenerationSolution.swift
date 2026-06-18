// highlight-aiImageGeneration-imports
import IMGLYEditor
import IMGLYPluginAIImageGeneration

// highlight-aiImageGeneration-imports
import SwiftUI

struct AIImageGenerationSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-aiImageGeneration-basicSetup
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(apiKey: secrets.gatewayApiKey),
        ))
      }
    // highlight-aiImageGeneration-basicSetup
  }
}

// MARK: - Choosing a Model

struct AIImageGenerationModelSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-aiImageGeneration-chooseModel
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(
            apiKey: secrets.gatewayApiKey,
            model: .gptImage2,
          ),
        ))
      }
    // highlight-aiImageGeneration-chooseModel
  }
}

// MARK: - Custom Styles

struct AIImageGenerationStylesSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-aiImageGeneration-customStyles
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(apiKey: secrets.gatewayApiKey),
          styles: [
            PromptStyle(
              id: "watercolor",
              displayName: "Watercolor",
              promptSnippet: "loose watercolor washes, gentle gradients, dreamy storybook feel",
            ),
            PromptStyle(
              id: "cyberpunk",
              displayName: "Cyberpunk",
              promptSnippet: "cyberpunk cityscape, glowing neon signage, dark atmosphere",
            ),
          ],
        ))
      }
    // highlight-aiImageGeneration-customStyles
  }
}

// MARK: - Error Handling

struct AIImageGenerationErrorHandlingSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")
  @State private var errorMessage: String?

  var body: some View {
    // highlight-aiImageGeneration-errorHandling
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(apiKey: secrets.gatewayApiKey),
          onError: { error in
            errorMessage = error.localizedDescription
          },
        ))
      }
      .alert("Generation Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "")
      }
    // highlight-aiImageGeneration-errorHandling
  }
}

// MARK: - Button Placement

struct AIImageGenerationPlacementSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-aiImageGeneration-buttonPlacement
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(apiKey: secrets.gatewayApiKey),
          dockModifier: { items, button in
            items.addLast { button }
          },
          inspectorBarModifier: { items, button in
            items.addLast { button }
          },
        ))
      }
    // highlight-aiImageGeneration-buttonPlacement
  }
}

// MARK: - Hide Style Picker

struct AIImageGenerationNoStylesSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-aiImageGeneration-hideStyles
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration()
        AIImageGenerationPlugin(options: .init(
          service: AIGatewayService(apiKey: secrets.gatewayApiKey),
          styles: [],
        ))
      }
    // highlight-aiImageGeneration-hideStyles
  }
}
