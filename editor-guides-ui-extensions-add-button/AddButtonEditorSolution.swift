// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
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
    DesignEditor(settings)
      // highlight-addNewButton-dock
      .imgly.modifyDockItems { context, items in
        items.addFirst {
          Dock.Button(
            // highlight-addNewButton-customID
            id: "my.app.dock.button.export",
            // highlight-addNewButton-customID
            action: { context in
              print("Custom export button tapped")
            },
            label: { context in
              Label("Export", systemImage: "square.and.arrow.up")
            },
          )
        }
      }
      // highlight-addNewButton-dock
      // highlight-addNewButton-canvasMenu
      .imgly.modifyCanvasMenuItems { context, items in
        items.addFirst {
          CanvasMenu.Button(
            id: "my.app.canvasMenu.button.favorite",
            action: { context in
              print("Favorite button tapped")
            },
            label: { context in
              Label("Favorite", systemImage: "star.fill")
            },
            // highlight-addNewButton-conditional
            isVisible: { context in
              // Only show for text blocks
              context.selection.type?.rawValue == "//ly.img.ubq/text"
            },
            // highlight-addNewButton-conditional
          )
        }
      }
      // highlight-addNewButton-canvasMenu
      // highlight-addNewButton-inspectorBar
      .imgly.modifyInspectorBarItems { context, items in
        items.addFirst {
          InspectorBar.Button(
            id: "my.app.inspectorBar.button.process",
            action: { context in
              print("Process button tapped")
            },
            label: { context in
              Label("Process", systemImage: "gearshape")
            },
            isEnabled: { context in
              // Only enabled if selection has fill
              context.selection.fillType != nil
            },
          )
        }
      }
      // highlight-addNewButton-inspectorBar
      .imgly.navigationBarItems { context in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
      }
      // highlight-addNewButton-navbar
      // highlight-addNewButton-navbarPlacement
      .imgly.modifyNavigationBarItems { context, items in
        // Add to right side (trailing)
        items.addFirst(placement: .topBarTrailing) {
          NavigationBar.Button(
            id: "my.app.navbar.button.help",
          ) { context in
            print("Help button tapped")
          } label: { context in
            Label("Help", systemImage: "questionmark.circle")
          }
        }

        // Add to left side (leading)
        items.addLast(placement: .topBarLeading) {
          NavigationBar.Button(
            id: "my.app.navbar.button.settings",
          ) { context in
            print("Settings button tapped")
          } label: { context in
            Label("Settings", systemImage: "gearshape")
          }
        }
      }
    // highlight-addNewButton-navbarPlacement
    // highlight-addNewButton-navbar
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
