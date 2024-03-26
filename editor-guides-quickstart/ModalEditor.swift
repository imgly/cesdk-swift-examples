import IMGLYEditor
import SwiftUI

struct ModalEditor<Editor: View, Label: View>: View {
  @ViewBuilder private let editor: () -> Editor
  @ViewBuilder private let dismissLabel: () -> Label

  init(@ViewBuilder editor: @escaping () -> Editor,
       @ViewBuilder dismissLabel: @escaping () -> Label = { SwiftUI.Label("Home", systemImage: "house") }) {
    self.editor = editor
    self.dismissLabel = dismissLabel
  }

  @State private var isBackButtonHidden = false
  @Environment(\.dismiss) private var dismiss

  @ViewBuilder private var dismissButton: some View {
    Button {
      dismiss()
    } label: {
      dismissLabel()
    }
  }

  var body: some View {
    // highlight-dismiss
    NavigationView {
      editor()
        .onPreferenceChange(BackButtonHiddenKey.self) { newValue in
          isBackButtonHidden = newValue
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if !isBackButtonHidden {
              dismissButton
            }
          }
        }
    }
    .navigationViewStyle(.stack)
    // highlight-dismiss
  }
}
