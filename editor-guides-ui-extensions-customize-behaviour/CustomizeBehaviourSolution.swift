import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// Editor demonstrating how to customize editor behaviour at runtime.
///
/// This example shows how to:
/// - Subscribe to engine events and editor state changes once the editor is ready
/// - Drive sheets through the editor's event channel
/// - Surface feedback as alerts and intercept the editor's built-in operations
/// - Toggle features at runtime from your own app state
/// - Switch the editor's appearance through the SwiftUI environment
struct CustomizeBehaviourSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  /// In a real app, derive this from your settings, feature flags, or workflow mode.
  static let textFeatureEnabled = false

  // The lesson: react to editing events and intercept default behaviour at runtime.
  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-customizeBehaviour-features
          // GuideEditorConfiguration ships an empty dock, so `items` sets the full list.
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.imagesLibrary()
              // Visible but greyed out and inactive until your app enables it.
              Dock.Buttons.textLibrary(isEnabled: { _ in Self.textFeatureEnabled })
            }
          }
          // highlight-customizeBehaviour-features
          // highlight-customizeBehaviour-listen
          builder.onLoaded { context, _ in
            let engine = context.engine

            // React to blocks being created, updated, or destroyed in the scene.
            context.task {
              for await events in engine.event.subscribe(to: []) {
                for event in events {
                  switch event.type {
                  case .created: print("Block created: \(event.block)")
                  case .updated: print("Block updated: \(event.block)")
                  case .destroyed: print("Block destroyed: \(event.block)")
                  @unknown default: break
                  }
                }
              }
            }

            // React to editor state changes, such as the current edit mode.
            context.task {
              for await _ in engine.editor.onStateChanged {
                print("Edit mode is now: \(engine.editor.getEditMode())")
              }
            }
          }
          // highlight-customizeBehaviour-listen
          // highlight-customizeBehaviour-alerts
          builder.onError { error, eventHandler, _ in
            eventHandler.send(.showErrorAlert(error))
          }
          builder.onClose { engine, eventHandler, _ in
            let hasUnsavedChanges = (try? engine.editor.canUndo()) ?? false
            if hasUnsavedChanges {
              eventHandler.send(.showCloseConfirmationAlert)
            } else {
              eventHandler.send(.closeEditor)
            }
          }
          // highlight-customizeBehaviour-alerts
        }
      }
  }

  // A second editor that opens a sheet from your own logic once it loads.
  // highlight-customizeBehaviour-sheets
  var sheetEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.imagesLibrary()
            }
          }
          builder.onLoaded { context, _ in
            context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.elementsTab }))
          }
        }
      }
  }

  // highlight-customizeBehaviour-sheets

  @State private var isPresented = false
  @State private var showsSheetDemo = false
  @State private var colorScheme: ColorScheme = .light

  var body: some View {
    VStack(spacing: 16) {
      Toggle("Open a sheet on load", isOn: $showsSheetDemo)
        .padding(.horizontal)
      Toggle("Dark appearance", isOn: Binding(
        get: { colorScheme == .dark },
        set: { colorScheme = $0 ? .dark : .light },
      ))
      .padding(.horizontal)
      Button("Use the Editor") {
        isPresented = true
      }
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        Group {
          if showsSheetDemo {
            sheetEditor
          } else {
            editor
          }
        }
        // highlight-customizeBehaviour-appearance
        .preferredColorScheme(colorScheme)
        // highlight-customizeBehaviour-appearance
      }
    }
  }
}

#Preview {
  CustomizeBehaviourSolution()
}
