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
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          ExportButton()
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
