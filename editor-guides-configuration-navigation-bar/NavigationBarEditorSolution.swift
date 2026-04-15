// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct NavigationBarEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          // highlight-navigationBarItems
          builder.navigationBar { navigationBar in
            navigationBar.items { _ in
              NavigationBar.ItemGroup(placement: .topBarLeading) {
                NavigationBar.Buttons.closeEditor()
              }
              NavigationBar.ItemGroup(placement: .topBarTrailing) {
                NavigationBar.Buttons.undo()
                NavigationBar.Buttons.redo()
                NavigationBar.Buttons.togglePagesMode()
                NavigationBar.Buttons.export()
              }
            }
            // highlight-navigationBarItems
            // highlight-modifyNavigationBarItems
            // highlight-modifyNavigationBarItemsSignature
            navigationBar.modify { _, items in
              // highlight-modifyNavigationBarItemsSignature
              // highlight-addFirst
              items.addFirst(placement: .topBarTrailing) {
                NavigationBar.Button(id: "my.package.inspectorBar.button.first") { _ in
                  print("First Button in top bar trailing placement group action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-addFirst
              // highlight-addLast
              items.addLast(placement: .topBarLeading) {
                NavigationBar.Button(id: "my.package.inspectorBar.button.last") { _ in
                  print("Last Button in top bar leading placement group action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-addLast
              // highlight-addAfter
              items.addAfter(id: NavigationBar.Buttons.ID.undo) {
                NavigationBar.Button(id: "my.package.inspectorBar.button.afterUndo") { _ in
                  print("After Undo")
                } label: { _ in
                  Label("After Undo", systemImage: "arrow.forward.square")
                }
              }
              // highlight-addAfter
              // highlight-addBefore
              items.addBefore(id: NavigationBar.Buttons.ID.redo) {
                NavigationBar.Button(id: "my.package.inspectorBar.button.beforeRedo") { _ in
                  print("Before Redo")
                } label: { _ in
                  Label("Before Redo", systemImage: "arrow.backward.square")
                }
              }
              // highlight-addBefore
              // highlight-replace
              items.replace(id: NavigationBar.Buttons.ID.closeEditor) {
                NavigationBar.Buttons.closeEditor(
                  label: { _ in Label("Cancel", systemImage: "xmark") },
                )
              }
              items.replace(id: NavigationBar.Buttons.ID.export) {
                NavigationBar.Buttons.export(
                  label: { _ in Label("Done", systemImage: "checkmark") },
                )
              }
              // highlight-replace
              // highlight-remove
              items.remove(id: NavigationBar.Buttons.ID.togglePagesMode)
            }
            // highlight-modifyNavigationBarItems
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

#Preview {
  NavigationBarEditorSolution()
}
