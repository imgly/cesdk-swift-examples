// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

/// Editor demonstrating how to declare and modify navigation bar items.
///
/// The `editor` view shows the lesson — what the documentation renders. It
/// replaces the `GuideEditorConfiguration` baseline with `navigationBar.items`
/// and then exercises every `navigationBar.modify` operation on the result.
/// The `body` presents `demoEditor`, which keeps only the clean replacement so
/// the guide hero shows a tidy customized navigation bar.
struct NavigationBarEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.navigationBar { navigationBar in
            // highlight-navigationBar-navigationBarItems
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
            // highlight-navigationBar-navigationBarItems
            // highlight-navigationBar-modifyNavigationBarItemsSignature
            navigationBar.modify { _, items in
              // highlight-navigationBar-modifyNavigationBarItemsSignature
              // highlight-navigationBar-addFirst
              items.addFirst(placement: .topBarTrailing) {
                NavigationBar.Button(id: "my.package.navigationBar.button.first") { _ in
                  print("First Button action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-navigationBar-addFirst
              // highlight-navigationBar-addLast
              items.addLast(placement: .topBarLeading) {
                NavigationBar.Button(id: "my.package.navigationBar.button.last") { _ in
                  print("Last Button action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-navigationBar-addLast
              // highlight-navigationBar-addAfter
              items.addAfter(id: NavigationBar.Buttons.ID.undo) {
                NavigationBar.Button(id: "my.package.navigationBar.button.afterUndo") { _ in
                  print("After Undo action")
                } label: { _ in
                  Label("After Undo", systemImage: "arrow.forward.square")
                }
              }
              // highlight-navigationBar-addAfter
              // highlight-navigationBar-addBefore
              items.addBefore(id: NavigationBar.Buttons.ID.redo) {
                NavigationBar.Button(id: "my.package.navigationBar.button.beforeRedo") { _ in
                  print("Before Redo action")
                } label: { _ in
                  Label("Before Redo", systemImage: "arrow.backward.square")
                }
              }
              // highlight-navigationBar-addBefore
              // highlight-navigationBar-replace
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
              // highlight-navigationBar-replace
              // highlight-navigationBar-remove
              items.remove(id: NavigationBar.Buttons.ID.togglePagesMode)
              // highlight-navigationBar-remove
            }
          }
        }
      }
  }

  // Demo scaffolding (not part of the lesson). Presents only the
  // `navigationBar.items` replacement so the guide hero shows a clean
  // customized navigation bar without the modify operations layered on top.
  // The default `onCreate` builds the scene; the navigation bar is always
  // visible, so no canvas content or selection is needed for the hero.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.navigationBar { navigationBar in
            navigationBar.items { _ in
              NavigationBar.ItemGroup(placement: .topBarLeading) {
                NavigationBar.Buttons.closeEditor()
              }
              NavigationBar.ItemGroup(placement: .topBarTrailing) {
                NavigationBar.Buttons.undo()
                NavigationBar.Buttons.redo()
                NavigationBar.Buttons.export()
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
        demoEditor
      }
    }
  }
}

#Preview {
  NavigationBarEditorSolution()
}
