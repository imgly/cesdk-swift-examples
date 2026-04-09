// swiftformat:disable unusedArguments
import IMGLYEditor
import SwiftUI

/// Design Editor demonstrating how to add custom buttons to different UI locations.
///
/// This example shows how to:
/// - Add a custom button to the Dock
/// - Add a custom button to the Canvas Menu
/// - Add a custom button to the Inspector Bar
/// - Add a custom button to the Navigation Bar
/// - Use conditional visibility and enabled states
/// - Apply proper ID naming conventions
struct AddButtonEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.navigationBar { navigationBar in
            navigationBar.items { _ in
              NavigationBar.ItemGroup(placement: .topBarLeading) {
                NavigationBar.Buttons.closeEditor()
              }
            }
            // highlight-addNewButton-navbar
            // highlight-addNewButton-navbarPlacement
            navigationBar.modify { _, items in
              // Add to trailing side
              items.addFirst(placement: .topBarTrailing) {
                NavigationBar.Button(
                  id: "my.app.navbar.button.help",
                ) { _ in
                  print("Help button tapped")
                } label: { _ in
                  Label("Help", systemImage: "questionmark.circle")
                }
              }

              // Add to leading side
              items.addLast(placement: .topBarLeading) {
                NavigationBar.Button(
                  id: "my.app.navbar.button.settings",
                ) { _ in
                  print("Settings button tapped")
                } label: { _ in
                  Label("Settings", systemImage: "gearshape")
                }
              }
            }
            // highlight-addNewButton-navbarPlacement
            // highlight-addNewButton-navbar
          }
          // highlight-addNewButton-dock
          builder.dock { dock in
            dock.modify { _, items in
              items.addFirst {
                Dock.Button(
                  // highlight-addNewButton-customID
                  id: "my.app.dock.button.export",
                  // highlight-addNewButton-customID
                  action: { _ in
                    print("Custom export button tapped")
                  },
                  label: { _ in
                    Label("Export", systemImage: "square.and.arrow.up")
                  },
                )
              }
            }
          }
          // highlight-addNewButton-dock
          // highlight-addNewButton-canvasMenu
          builder.canvasMenu { canvasMenu in
            canvasMenu.modify { _, items in
              items.addFirst {
                CanvasMenu.Button(
                  id: "my.app.canvasMenu.button.favorite",
                  action: { _ in
                    print("Favorite button tapped")
                  },
                  label: { _ in
                    Label("Favorite", systemImage: "star.fill")
                  },
                  // highlight-addNewButton-conditional
                  // Disable for stickers (shows grayed out)
                  isEnabled: { context in
                    context.selection.kind != "sticker"
                  },
                  // Only show for graphic blocks (hidden otherwise)
                  isVisible: { context in
                    context.selection.type == .graphic
                  },
                  // highlight-addNewButton-conditional
                )
              }
            }
          }
          // highlight-addNewButton-canvasMenu
          // highlight-addNewButton-inspectorBar
          builder.inspectorBar { inspectorBar in
            inspectorBar.modify { _, items in
              items.addFirst {
                InspectorBar.Button(
                  id: "my.app.inspectorBar.button.process",
                  action: { _ in
                    print("Process button tapped")
                  },
                  label: { _ in
                    Label("Process", systemImage: "gearshape")
                  },
                  // Disable for text blocks (shows grayed out)
                  isEnabled: { context in
                    context.selection.type != .text
                  },
                  // Only show for blocks with fill (hidden otherwise)
                  isVisible: { context in
                    context.selection.fillType != nil
                  },
                )
              }
            }
          }
          // highlight-addNewButton-inspectorBar
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
  AddButtonEditorSolution()
}
