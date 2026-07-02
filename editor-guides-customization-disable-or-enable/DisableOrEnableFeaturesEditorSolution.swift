import IMGLYEditor
import SwiftUI

/// Editor demonstrating how to disable or enable editor features.
///
/// This example shows how to:
/// - Disable a feature so its control is visible but inactive
/// - Conditionally enable a feature based on the current selection
/// - Conditionally show or hide a feature based on the current selection
/// - Gate a feature on application state such as a setting or feature flag
struct DisableOrEnableFeaturesEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  enum Demo: String, CaseIterable, Identifiable {
    case disableFeature = "Disable Feature"
    case conditionalEnable = "Conditional Enable"
    case conditionalVisibility = "Conditional Visibility"
    case appState = "App State"
    var id: Self { self }
  }

  @State private var selectedDemo: Demo = .disableFeature
  @State private var isPresented = false

  // highlight-disableEnable-disableFeature
  var editorWithDisabledFeature: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.imagesLibrary()
              Dock.Buttons.textLibrary()
              // Visible but greyed out and non-interactive.
              Dock.Buttons.shapesLibrary(isEnabled: { _ in false })
            }
          }
        }
      }
  }

  // highlight-disableEnable-disableFeature

  // highlight-disableEnable-conditionalEnable
  var editorWithConditionalEnable: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
              // Enabled only when the selected block is a text block.
              CanvasMenu.Buttons.duplicate(isEnabled: { context in
                context.selection.type == .text
              })
              CanvasMenu.Buttons.delete()
            }
          }
        }
      }
  }

  // highlight-disableEnable-conditionalEnable

  // highlight-disableEnable-conditionalVisibility
  var editorWithConditionalVisibility: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
              CanvasMenu.Buttons.delete(isVisible: { context in
                try context.engine.block.isAllowedByScope(context.selection.block, key: "lifecycle/destroy")
                  && context.selection.type != .text
              })
              CanvasMenu.Buttons.duplicate()
            }
          }
        }
      }
  }

  // highlight-disableEnable-conditionalVisibility

  // highlight-disableEnable-appState
  var editorWithAppStateGate: some View {
    // In a real app, derive this from your settings, feature flags, or workflow mode.
    let stickersEnabled = false
    return Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.imagesLibrary()
              Dock.Buttons.stickersLibrary(isEnabled: { _ in stickersEnabled })
            }
          }
        }
      }
  }

  // highlight-disableEnable-appState

  var body: some View {
    VStack(spacing: 16) {
      Picker("Demo", selection: $selectedDemo) {
        ForEach(Demo.allCases) { demo in
          Text(demo.rawValue).tag(demo)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)

      Button("Use the Editor") {
        isPresented = true
      }
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        switch selectedDemo {
        case .disableFeature:
          editorWithDisabledFeature
        case .conditionalEnable:
          editorWithConditionalEnable
        case .conditionalVisibility:
          editorWithConditionalVisibility
        case .appState:
          editorWithAppStateGate
        }
      }
    }
  }
}

#Preview {
  DisableOrEnableFeaturesEditorSolution()
}
