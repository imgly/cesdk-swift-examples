// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

struct DockEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  /// The lesson shown in the guide and the view the showcase presents.
  ///
  /// `GuideEditorConfiguration` ships an empty dock, so the full item list is
  /// declared up front with `dock.items`. The default `onCreate` builds the
  /// 1080×1080 scene the dock needs to mount, so no extra scaffolding is required.
  var editor: some View {
    // highlight-dock-editor
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.photoRoll()
              Dock.Buttons.systemCamera()
              Dock.Buttons.imagesLibrary()
              Dock.Buttons.textLibrary()
              Dock.Buttons.shapesLibrary()
              Dock.Buttons.stickersLibrary()
              Dock.Buttons.resize()
            }
          }
        }
      }
    // highlight-dock-editor
  }

  /// A second configuration that declares the same starting list and then adjusts
  /// it with `dock.modify`. `modify` operates on an existing list, so the list is
  /// declared with `dock.items` first; the guide renders only the `modify` block.
  var modifyEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.photoRoll()
              Dock.Buttons.systemCamera()
              Dock.Buttons.imagesLibrary()
              Dock.Buttons.textLibrary()
              Dock.Buttons.shapesLibrary()
              Dock.Buttons.stickersLibrary()
              Dock.Buttons.resize()
            }
            // highlight-dock-modify-signature
            dock.modify { _, items in
              // highlight-dock-modify-signature
              // highlight-dock-addFirst
              items.addFirst {
                Dock.Button(id: "my.package.dock.button.first") { _ in
                  print("First Button action")
                } label: { _ in
                  Label("First Button", systemImage: "arrow.backward.circle")
                }
              }
              // highlight-dock-addFirst
              // highlight-dock-addLast
              items.addLast {
                Dock.Button(id: "my.package.dock.button.last") { _ in
                  print("Last Button action")
                } label: { _ in
                  Label("Last Button", systemImage: "arrow.forward.circle")
                }
              }
              // highlight-dock-addLast
              // highlight-dock-addAfter
              items.addAfter(id: Dock.Buttons.ID.photoRoll) {
                Dock.Button(id: "my.package.dock.button.afterPhotoRoll") { _ in
                  print("After Photo Roll action")
                } label: { _ in
                  Label("After Photo Roll", systemImage: "arrow.forward.square")
                }
              }
              // highlight-dock-addAfter
              // highlight-dock-addBefore
              items.addBefore(id: Dock.Buttons.ID.systemCamera) {
                Dock.Button(id: "my.package.dock.button.beforeSystemCamera") { _ in
                  print("Before Camera action")
                } label: { _ in
                  Label("Before Camera", systemImage: "arrow.backward.square")
                }
              }
              // highlight-dock-addBefore
              // highlight-dock-replace
              items.replace(id: Dock.Buttons.ID.textLibrary) {
                Dock.Button(id: "my.package.dock.button.replacedTextLibrary") { _ in
                  print("Replaced Text action")
                } label: { _ in
                  Label("Replaced Text", systemImage: "arrow.uturn.down.square")
                }
              }
              // highlight-dock-replace
              // highlight-dock-remove
              items.remove(id: Dock.Buttons.ID.shapesLibrary)
              // highlight-dock-remove
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

#Preview {
  DockEditorSolution()
}
