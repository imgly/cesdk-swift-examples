// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct DockItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      .imgly.dockItems { context in
        // highlight-predefinedButton
        Dock.Buttons.elementsLibrary()

        // highlight-customizePredefinedButton
        Dock.Buttons.imagesLibrary(
          // highlight-customizePredefinedButton-action
          action: { context in
            context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.imagesTab }))
          },
          // highlight-customizePredefinedButton-action
          // highlight-customizePredefinedButton-title
          title: { context in Text("Image") },
          // highlight-customizePredefinedButton-icon
          icon: { context in Image.imgly.addImage },
          // highlight-customizePredefinedButton-isEnabled
          isEnabled: { context in true },
          // highlight-customizePredefinedButton-isVisible
          isVisible: { context in true },
        )
        // highlight-customizePredefinedButton

        // highlight-newButton
        Dock.Button(
          // highlight-newButton-id
          id: "my.package.dock.button.newButton",
          // highlight-newButton-action
        ) { context in
          print("New Button action")
          // highlight-newButton-action
          // highlight-newButton-label
        } label: { context in
          Label("New Button", systemImage: "star.circle")
          // highlight-newButton-label
          // highlight-newButton-isEnabled
        } isEnabled: { context in
          true
          // highlight-newButton-isEnabled
          // highlight-newButton-isVisible
        } isVisible: { context in
          true
        }
        // highlight-newButton-isVisible
        // highlight-newButton

        // highlight-newCustomItem
        CustomDockItem()
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

// highlight-newCustomItem-conformance
private struct CustomDockItem: Dock.Item {
  // highlight-newCustomItem-id
  var id: EditorComponentID { "my.package.dock.newCustomItem" }

  // highlight-newCustomItem-body
  func body(_ context: Dock.Context) throws -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(.conicGradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red], center: .center))
      Text("New Custom Item")
        .padding(4)
    }
    .onTapGesture {
      print("New Custom Item action")
    }
  }

  // highlight-newCustomItem-body
  // highlight-newCustomItem-isVisible
  func isVisible(_ context: Dock.Context) throws -> Bool {
    true
  }
  // highlight-newCustomItem-isVisible
}

// highlight-newCustomItem-conformance

#Preview {
  DockItemEditorSolution()
}
