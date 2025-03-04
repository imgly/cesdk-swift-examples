// swiftlint:disable unused_closure_parameter
// swiftformat:disable unusedArguments
import IMGLYDesignEditor
import SwiftUI

struct InspectorBarEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var editor: some View {
    // highlight-editor
    DesignEditor(settings)
      // highlight-inspectorBarItems
      .imgly.inspectorBarItems { context in
        InspectorBar.Buttons.replace() // Video, Image, Sticker, Audio
        InspectorBar.Buttons.editText() // Text
        InspectorBar.Buttons.formatText() // Text
        InspectorBar.Buttons.fillStroke() // Page, Video, Image, Shape, Text
        InspectorBar.Buttons.editVoiceover() // Voiceover
        InspectorBar.Buttons.volume() // Video, Audio, Voiceover
        InspectorBar.Buttons.crop() // Video, Image
        InspectorBar.Buttons.adjustments() // Video, Image
        InspectorBar.Buttons.filter() // Video, Image
        InspectorBar.Buttons.effect() // Video, Image
        InspectorBar.Buttons.blur() // Video, Image
        InspectorBar.Buttons.shape() // Video, Image, Shape
        InspectorBar.Buttons.selectGroup() // Video, Image, Sticker, Shape, Text
        InspectorBar.Buttons.enterGroup() // Group
        InspectorBar.Buttons.layer() // Video, Image, Sticker, Shape, Text
        InspectorBar.Buttons.split() // Video, Image, Sticker, Shape, Text, Audio
        InspectorBar.Buttons.moveAsClip() // Video, Image, Sticker, Shape, Text
        InspectorBar.Buttons.moveAsOverlay() // Video, Image, Sticker, Shape, Text
        InspectorBar.Buttons.reorder() // Video, Image, Sticker, Shape, Text
        InspectorBar.Buttons.duplicate() // Video, Image, Sticker, Shape, Text, Audio
        InspectorBar.Buttons.delete() // Video, Image, Sticker, Shape, Text, Audio, Voiceover
      }
      // highlight-inspectorBarItems
      // highlight-modifyInspectorBarItems
      .imgly.modifyInspectorBarItems { context, items in
        // highlight-addFirst
        items.addFirst {
          InspectorBar.Button(id: "my.package.inspectorBar.button.first") { context in
            print("First Button action")
          } label: { context in
            Label("First Button", systemImage: "arrow.backward.circle")
          }
        }
        // highlight-addFirst
        // highlight-addLast
        items.addLast {
          InspectorBar.Button(id: "my.package.inspectorBar.button.last") { context in
            print("Last Button action")
          } label: { context in
            Label("Last Button", systemImage: "arrow.forward.circle")
          }
        }
        // highlight-addLast
        // highlight-addAfter
        items.addAfter(id: InspectorBar.Buttons.ID.layer) {
          InspectorBar.Button(id: "my.package.inspectorBar.button.afterLayer") { context in
            print("After Layer action")
          } label: { context in
            Label("After Layer", systemImage: "arrow.forward.square")
          }
        }
        // highlight-addAfter
        // highlight-addBefore
        items.addBefore(id: InspectorBar.Buttons.ID.crop) {
          InspectorBar.Button(id: "my.package.inspectorBar.button.beforeCrop") { context in
            print("Before Crop action")
          } label: { context in
            Label("Before Crop", systemImage: "arrow.backward.square")
          }
        }
        // highlight-addBefore
        // highlight-replace
        items.replace(id: InspectorBar.Buttons.ID.formatText) {
          InspectorBar.Button(id: "my.package.inspectorBar.button.replacedTextLibrary") { context in
            print("Replaced Format action")
          } label: { context in
            Label("Replaced Format", systemImage: "arrow.uturn.down.square")
          }
        }
        // highlight-replace
        // highlight-remove
        items.remove(id: InspectorBar.Buttons.ID.delete)
      }
    // highlight-modifyInspectorBarItems
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
  InspectorBarEditorSolution()
}
