// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct NavigationBarItemEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.navigationBar { navigationBar in
            navigationBar.items { _ in
              NavigationBar.ItemGroup(placement: .topBarLeading) {
                // highlight-navigationBar-predefinedButton
                NavigationBar.Buttons.closeEditor()
              }

              NavigationBar.ItemGroup(placement: .principal) {
                // highlight-navigationBar-customizePredefinedButton
                NavigationBar.Buttons.undo(
                  // highlight-navigationBar-customizePredefinedButton-action
                  action: { context in
                    try context.engine?.editor.undo()
                  },
                  // highlight-navigationBar-customizePredefinedButton-action
                  // highlight-navigationBar-customizePredefinedButton-label
                  label: { context in
                    Label {
                      Text(.imgly.localized("ly_img_editor_navigation_bar_button_undo"))
                    } icon: {
                      Image.imgly.undo
                    }
                    .opacity(context.state.viewMode == .preview ? 0 : 1)
                    .labelStyle(.imgly.adaptiveIconOnly)
                  },
                  // highlight-navigationBar-customizePredefinedButton-label
                  // highlight-navigationBar-customizePredefinedButton-isEnabled
                  isEnabled: { context in
                    try !context.state.isCreating &&
                      context.state.viewMode != .preview &&
                      context.engine?.editor.canUndo() == true
                  },
                  // highlight-navigationBar-customizePredefinedButton-isEnabled
                  // highlight-navigationBar-customizePredefinedButton-isVisible
                  isVisible: { _ in true },
                )
                // highlight-navigationBar-customizePredefinedButton

                // highlight-navigationBar-newButton
                NavigationBar.Button(
                  // highlight-navigationBar-newButton-id
                  id: "my.package.navigationBar.button.newButton",
                  // highlight-navigationBar-newButton-action
                ) { _ in
                  print("New Button action")
                  // highlight-navigationBar-newButton-action
                  // highlight-navigationBar-newButton-label
                } label: { _ in
                  Label("New Button", systemImage: "star.circle")
                  // highlight-navigationBar-newButton-label
                  // highlight-navigationBar-newButton-isEnabled
                } isEnabled: { _ in
                  true
                  // highlight-navigationBar-newButton-isEnabled
                  // highlight-navigationBar-newButton-isVisible
                } isVisible: { _ in
                  true
                }
                // highlight-navigationBar-newButton-isVisible
                // highlight-navigationBar-newButton
              }

              NavigationBar.ItemGroup(placement: .topBarTrailing) {
                // highlight-navigationBar-newCustomItem
                CustomNavigationBarItem()
              }
            }
          }
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

// highlight-navigationBar-newCustomItemConformance
private struct CustomNavigationBarItem: NavigationBar.Item {
  // highlight-navigationBar-newCustomItem-id
  var id: EditorComponentID { "my.package.navigationBar.newCustomItem" }

  // highlight-navigationBar-newCustomItem-body
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

  // highlight-navigationBar-newCustomItem-body
  // highlight-navigationBar-newCustomItem-isVisible
  func isVisible(_ context: NavigationBar.Context) throws -> Bool {
    true
  }
  // highlight-navigationBar-newCustomItem-isVisible
}

// highlight-navigationBar-newCustomItemConformance

#Preview {
  NavigationBarItemEditorSolution()
}
