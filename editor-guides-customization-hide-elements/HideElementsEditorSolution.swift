import IMGLYDesignEditor
import SwiftUI

/// Design Editor demonstrating how to hide UI elements.
///
/// This example shows how to:
/// - Hide the dock completely (the only UI component that fully hides)
/// - Remove specific items from any UI component
/// - Understand the distinction between hiding and removing
struct HideElementsEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // highlight-hideElements-dock
  // To hide the dock completely, provide an empty closure to .imgly.dockItems
  // The dock is the only UI component that fully hides when given no items
  var editorWithHiddenDock: some View {
    DesignEditor(settings)
      .imgly.dockItems { _ in
        // Empty - dock will be completely hidden
      }
  }

  // highlight-hideElements-dock

  // highlight-hideElements-remove
  // To remove specific items from any component, use the modify variants
  // The component container remains visible, only the specified items are removed
  var editorWithRemovedItems: some View {
    DesignEditor(settings)
      // highlight-hideElements-dockRemove
      .imgly.modifyDockItems { _, items in
        items.remove(id: Dock.Buttons.ID.elementsLibrary)
        items.remove(id: Dock.Buttons.ID.shapesLibrary)
      }
      // highlight-hideElements-dockRemove
      // highlight-hideElements-navbarRemove
      .imgly.modifyNavigationBarItems { _, items in
        items.remove(id: NavigationBar.Buttons.ID.undo)
        items.remove(id: NavigationBar.Buttons.ID.redo)
      }
    // highlight-hideElements-navbarRemove
  }

  // highlight-hideElements-remove

  @State private var isPresented = false
  @State private var showHiddenDock = true

  var body: some View {
    VStack {
      Toggle("Hide Dock Completely", isOn: $showHiddenDock)
        .padding()

      Button("Use the Editor") {
        isPresented = true
      }
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        if showHiddenDock {
          editorWithHiddenDock
        } else {
          editorWithRemovedItems
        }
      }
    }
  }
}

#Preview {
  HideElementsEditorSolution()
}
