import IMGLYEditor
import SwiftUI

/// Editor demonstrating how to hide UI elements.
///
/// This example shows how to:
/// - Hide the dock completely
/// - Remove specific items from each UI component
/// - Combine approaches to create a minimal UI
struct HideElementsEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  enum Demo: String, CaseIterable, Identifiable {
    case hideDock = "Hide Dock"
    case removeItems = "Remove Items"
    case minimalUI = "Minimal UI"
    var id: Self { self }
  }

  @State private var selectedDemo: Demo = .hideDock
  @State private var isPresented = false

  // highlight-hideElements-hideDock
  var editorWithHiddenDock: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              // Empty — hides the dock completely
            }
          }
        }
      }
  }

  // highlight-hideElements-hideDock

  // highlight-hideElements-removeItems
  var editorWithItemsRemoved: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-hideElements-removeDock
          builder.dock { dock in
            dock.items { _ in
              Dock.Button(id: "my.app.dock.elements") { _ in } label: { _ in
                Label("Elements", systemImage: "square.on.circle")
              }
              Dock.Button(id: "my.app.dock.images") { _ in } label: { _ in
                Label("Images", systemImage: "photo")
              }
              Dock.Button(id: "my.app.dock.text") { _ in } label: { _ in
                Label("Text", systemImage: "textformat")
              }
              Dock.Button(id: "my.app.dock.shapes") { _ in } label: { _ in
                Label("Shapes", systemImage: "square.on.circle.dashed")
              }
            }
            dock.modify { _, items in
              items.remove(id: "my.app.dock.elements")
              items.remove(id: "my.app.dock.shapes")
            }
          }
          // highlight-hideElements-removeDock
          // highlight-hideElements-removeNavbar
          builder.navigationBar { navigationBar in
            navigationBar.modify { _, items in
              items.remove(id: NavigationBar.Buttons.ID.undo)
              items.remove(id: NavigationBar.Buttons.ID.redo)
            }
          }
          // highlight-hideElements-removeNavbar
          // highlight-hideElements-removeCanvasMenu
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
              CanvasMenu.Buttons.bringForward()
              CanvasMenu.Buttons.sendBackward()
              CanvasMenu.Buttons.delete()
            }
            canvasMenu.modify { _, items in
              items.remove(id: CanvasMenu.Buttons.ID.bringForward)
            }
          }
          // highlight-hideElements-removeCanvasMenu
          // highlight-hideElements-removeInspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.items { _ in
              InspectorBar.Buttons.crop()
              InspectorBar.Buttons.adjustments()
              InspectorBar.Buttons.filter()
            }
            inspectorBar.modify { _, items in
              items.remove(id: InspectorBar.Buttons.ID.crop)
            }
          }
          // highlight-hideElements-removeInspectorBar
        }
      }
  }

  // highlight-hideElements-removeItems

  // highlight-hideElements-minimalUI
  var editorWithMinimalUI: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in }
          }
          builder.navigationBar { navigationBar in
            navigationBar.items { _ in
              NavigationBar.ItemGroup(placement: .topBarLeading) {
                NavigationBar.Buttons.closeEditor()
              }
            }
          }
        }
      }
  }

  // highlight-hideElements-minimalUI

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
        case .hideDock:
          editorWithHiddenDock
        case .removeItems:
          editorWithItemsRemoved
        case .minimalUI:
          editorWithMinimalUI
        }
      }
    }
  }
}

#Preview {
  HideElementsEditorSolution()
}
