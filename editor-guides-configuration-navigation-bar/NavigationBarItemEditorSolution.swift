// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct NavigationBarItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    DesignEditor(settings)
      .imgly.navigationBarItems { context in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          // highlight-predefinedButton
          NavigationBar.Buttons.closeEditor()
        }

        NavigationBar.ItemGroup(placement: .principal) {
          // highlight-customizePredefinedButton
          NavigationBar.Buttons.undo(
            // highlight-customizePredefinedButton-action
            action: { context in
              try context.engine?.editor.undo()
            },
            // highlight-customizePredefinedButton-action
            // highlight-customizePredefinedButton-label
            label: { context in
              Label { Text("Undo") } icon: { Image.imgly.undo }
                .opacity(context.state.viewMode == .preview ? 0 : 1)
                .labelStyle(.imgly.adaptiveIconOnly)
            },
            // highlight-customizePredefinedButton-label
            // highlight-customizePredefinedButton-isEnabled
            isEnabled: { context in
              try !context.state.isCreating &&
                context.state.viewMode != .preview &&
                context.engine?.editor.canUndo() == true
            },
            // highlight-customizePredefinedButton-isEnabled
            // highlight-customizePredefinedButton-isVisible
            isVisible: { context in true },
          )
          // highlight-customizePredefinedButton

          // highlight-newButton
          NavigationBar.Button(
            // highlight-newButton-id
            id: "my.package.navigationBar.button.newButton",
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
        }

        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          // highlight-newCustomItem
          CustomNavigationBarItem()
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

// highlight-newCustomItem-conformance
private struct CustomNavigationBarItem: NavigationBar.Item {
  // highlight-newCustomItem-id
  var id: EditorComponentID { "my.package.navigationBar.newCustomItem" }

  // highlight-newCustomItem-body
  func body(_ context: NavigationBar.Context) throws -> some View {
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
  func isVisible(_ context: NavigationBar.Context) throws -> Bool {
    true
  }
  // highlight-newCustomItem-isVisible
}

// highlight-newCustomItem-conformance

#Preview {
  NavigationBarItemEditorSolution()
}
