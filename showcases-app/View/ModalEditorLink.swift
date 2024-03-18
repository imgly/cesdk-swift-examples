import SwiftUI

struct ModalEditorLink<Editor: View, Label: View>: View {
  @ViewBuilder let editor: () -> Editor
  @ViewBuilder let label: () -> Label

  @State private var isPresented = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      label()
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor(editor: editor)
    }
  }
}
