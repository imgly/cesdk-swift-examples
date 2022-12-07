import SwiftUI

extension PreviewProvider {
  @ViewBuilder static var defaultPreviews: some View {
    defaultPreviews()
  }

  @ViewBuilder static func defaultPreviews(sheet: SheetState? = nil) -> some View {
    NavigationView {
      ContentView(sheet: sheet)
    }
    NavigationView {
      ContentView(sheet: sheet)
    }
    .nonDefaultPreviewSettings()
  }
}
