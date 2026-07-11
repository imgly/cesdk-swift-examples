// swiftformat:disable unusedArguments
import IMGLYEditor
import IMGLYEngine
import SwiftUI

struct RegisterNewComponentSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey, // pass nil for evaluation mode with watermark
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              // highlight-registerNewComponent-predefinedButton
              Dock.Buttons.elementsLibrary()
              // highlight-registerNewComponent-predefinedButton

              // highlight-registerNewComponent-customizeButton
              Dock.Buttons.imagesLibrary(
                action: { context in
                  context.eventHandler.send(.openSheet(type: .libraryAdd { context.assetLibrary.imagesTab }))
                },
                title: { _ in Text("Image") },
                icon: { _ in Image.imgly.addImage },
              )
              // highlight-registerNewComponent-customizeButton

              // highlight-registerNewComponent-newButton
              Dock.Button(
                id: "my.package.dock.button.export",
                action: { _ in print("Export tapped") },
                label: { _ in Label("Export", systemImage: "square.and.arrow.up") },
              )
              // highlight-registerNewComponent-newButton

              // highlight-registerNewComponent-customItem
              StatusBadgeItem()
              // highlight-registerNewComponent-customItem

              // highlight-registerNewComponent-reusableDock
              Dock.Button(
                id: "my.package.dock.button.brandKit",
                action: { _ in print("Brand Kit tapped") },
                label: { _ in BrandKitLabel() },
              )
              // highlight-registerNewComponent-reusableDock
            }
          }
          builder.canvasMenu { canvasMenu in
            canvasMenu.items { _ in
              // highlight-registerNewComponent-reusableCanvasMenu
              CanvasMenu.Button(
                id: "my.package.canvasMenu.button.brandKit",
                action: { _ in print("Brand Kit tapped") },
                label: { _ in BrandKitLabel() },
              )
              // highlight-registerNewComponent-reusableCanvasMenu

              // highlight-registerNewComponent-visibility
              CanvasMenu.Button(
                id: "my.package.canvasMenu.button.editCopy",
                action: { _ in print("Edit Copy tapped") },
                label: { _ in Label("Edit Copy", systemImage: "text.cursor") },
                isVisible: { context in context.selection.type == .text },
              )
              // highlight-registerNewComponent-visibility
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

// highlight-registerNewComponent-reusableView
private struct BrandKitLabel: View {
  var body: some View {
    Label("Brand Kit", systemImage: "paintpalette")
  }
}

// highlight-registerNewComponent-reusableView

// highlight-registerNewComponent-customItem-conformance
private struct StatusBadgeItem: Dock.Item {
  var id: EditorComponentID { "my.package.dock.statusBadge" }

  func body(_ context: Dock.Context) throws -> some View {
    Text("Beta")
      .font(.caption.weight(.semibold))
      .foregroundStyle(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(.tint, in: Capsule())
      .onTapGesture { print("Beta badge tapped") }
  }
}

// highlight-registerNewComponent-customItem-conformance

#Preview {
  RegisterNewComponentSolution()
}
