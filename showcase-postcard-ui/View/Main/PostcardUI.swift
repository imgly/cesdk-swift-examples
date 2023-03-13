import IMGLYEditorUI
import SwiftUI

enum Page: Int, Localizable {
  case design, write

  var description: String {
    switch self {
    case .design: return "Design"
    case .write: return "Write"
    }
  }

  var previous: Page? { Self(rawValue: index - 1) }
  var next: Page? { Self(rawValue: index + 1) }
  var index: Int { rawValue }
}

public struct PostcardUI: View {
  @StateObject private var interactor = Interactor.postcardUI

  private let url: URL

  public init(scene url: URL) {
    self.url = url
  }

  var page: Page? { Page(rawValue: interactor.page) }

  var isBackButtonHidden: Bool { !interactor.isEditing || page?.previous != nil }

  public var body: some View {
    EditorUI(scene: url)
      .navigationBarBackButtonHidden(isBackButtonHidden)
      .preference(key: BackButtonHiddenKey.self, value: isBackButtonHidden)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if interactor.isEditing, let previousPage = page?.previous {
            PageNavigationButton(to: previousPage, direction: .backward)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          if let nextPage = page?.next {
            if interactor.isEditing {
              PageNavigationButton(to: nextPage, direction: .forward)
            }
          } else {
            ExportButton()
              .labelStyle(.adaptiveIconOnly)
          }
        }
      }
      .interactor(interactor)
  }
}

struct PostcardUI_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
