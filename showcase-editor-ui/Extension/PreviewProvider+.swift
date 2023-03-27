import SwiftUI

extension PreviewProvider {
  private static var url: URL { Bundle.main.url(forResource: "apparel-ui-b-1-default", withExtension: "scene")! }

  @ViewBuilder static var defaultPreviews: some View {
    defaultPreviews()
  }

  @ViewBuilder static func editorUI(sheet: SheetState?) -> some View {
    NavigationView {
      EditorUIPreview(scene: Self.url, sheet: sheet)
    }
  }

  @ViewBuilder static func defaultPreviews(sheet: SheetState? = nil) -> some View {
    Group {
      editorUI(sheet: sheet)
      editorUI(sheet: sheet).nonDefaultPreviewSettings()
    }
    .navigationViewStyle(.stack)
  }
}

private struct EditorUIPreview: View {
  @StateObject private var interactor: Interactor

  private let url: URL

  init(scene url: URL, sheet: SheetState?) {
    self.url = url
    _interactor = .init(wrappedValue: Interactor(behavior: .default, sheet: sheet))
  }

  var body: some View {
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
