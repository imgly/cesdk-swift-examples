import IMGLYEditor
import SwiftUI

/// Editor demonstrating how to change the UI font design.
///
/// The `editor` view shows the lesson — what the documentation renders.
/// The `body` uses `demoEditor`, which extends the same `GuideEditorConfiguration`
/// with a dock containing default library buttons so the screenshot surfaces
/// the customized font on visible UI labels.
///
/// `.fontDesign(_:)` requires iOS 16.1, so the struct is marked accordingly.
@available(iOS 16.1, *)
struct ChangeUIFontSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  var editor: some View {
    // highlight-changeUIFont-fontDesign
    Editor(settings)
      .imgly.configuration { GuideEditorConfiguration() }
      .fontDesign(.serif)
    // highlight-changeUIFont-fontDesign
  }

  // Targeted alternative: apply a registered custom font to a single button's
  // label without changing its wording. Rebuild the button's default localized
  // title and restyle it. "BrandFont" is a placeholder for the PostScript name
  // of a font your app has registered.
  var customLabelEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          // highlight-changeUIFont-buttonLabelFont
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary(title: { _ in
                Text(.imgly.localized("ly_img_editor_dock_button_elements"))
                  .font(.custom("BrandFont", size: 12))
              })
            }
          }
          // highlight-changeUIFont-buttonLabelFont
        }
      }
  }

  // Demo scaffolding (not part of the lesson). Adds dock buttons so the
  // screenshot shows the customized UI font on visible labels.
  private var demoEditor: some View {
    Editor(settings)
      .imgly.configuration {
        GuideEditorConfiguration { builder in
          builder.dock { dock in
            dock.items { _ in
              Dock.Buttons.elementsLibrary()
              Dock.Buttons.imagesLibrary()
              Dock.Buttons.textLibrary()
              Dock.Buttons.shapesLibrary()
              Dock.Buttons.stickersLibrary()
            }
          }
        }
      }
      .fontDesign(.serif)
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

@available(iOS 16.1, *)
#Preview {
  ChangeUIFontSolution()
}
