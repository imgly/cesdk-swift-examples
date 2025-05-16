import SwiftUI

struct ModalEditor<Editor: View>: View {
  @ViewBuilder private let editor: () -> Editor

  init(@ViewBuilder editor: @escaping () -> Editor) {
    self.editor = editor
  }

  var body: some View {
    // highlight-dismiss
    NavigationView {
      editor()
    }
    .navigationViewStyle(.stack)
    // highlight-dismiss
  }
}
