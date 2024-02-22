import IMGLYEditor
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

struct ModalEditor<Editor: View>: View {
  @ViewBuilder let editor: () -> Editor

  @State private var isBackButtonHidden = false
  @Environment(\.dismiss) private var dismiss

  @ViewBuilder private var homeButton: some View {
    Button {
      dismiss()
    } label: {
      Label("Home", systemImage: "house")
    }
  }

  var body: some View {
    NavigationView {
      editor()
        .onPreferenceChange(BackButtonHiddenKey.self) { newValue in
          isBackButtonHidden = newValue
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if !isBackButtonHidden {
              homeButton
            }
          }
        }
    }
    .navigationViewStyle(.stack)
  }
}
