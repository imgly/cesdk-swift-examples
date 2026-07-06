import IMGLYEditor
import SwiftUI

@MainActor var settings: EngineSettings {
  EngineSettings(license: secrets.licenseKey, userID: "showcases-app-user", baseURL: secrets.baseURL)
}

class ShowcasesEditorConfiguration: EditorConfiguration {
  override var navigationBar: NavigationBar.Configuration? {
    NavigationBar.Configuration { navigationBar in
      navigationBar.modify { _, items in
        items.replace(id: NavigationBar.Buttons.ID.closeEditor) {
          NavigationBar.Buttons.closeEditor(
            label: { _ in SwiftUI.Label("Home", systemImage: "house") },
          )
        }
      }
    }
  }
}

final class CustomEditorConfiguration: ShowcasesEditorConfiguration {
  override var assetLibrary: AssetLibraryConfiguration? {
    AssetLibraryConfiguration { builder in
      builder.modify { categories in
        categories.modifySections(of: AssetLibraryCategory.ID.images) { sections in
          let id = UnsplashAssetSource.id
          sections.addFirst(.image(id: id, title: "Unsplash", source: .init(id: id)))
        }
      }
    }
  }
}
