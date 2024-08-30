import IMGLYEditorUI
import SwiftUI

public struct ApparelUI: View {
  @StateObject private var interactor = Interactor.apparelUI

  private let url: URL

  public init(scene url: URL) {
    self.url = url
  }

  public var body: some View {
    EditorUI(scene: url)
      .navigationTitle("")
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            UndoRedoButtons()
            PreviewButton()
            ExportButton()
          }
          .labelStyle(.adaptiveIconOnly)
        }
      }
      .interactor(interactor)
  }
}

struct ApparelUI_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
