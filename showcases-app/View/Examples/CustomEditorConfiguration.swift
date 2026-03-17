import IMGLYEditor
import SwiftUI

@MainActor var settings: EngineSettings {
  if let baseURL = secrets.baseURL {
    .init(license: secrets.licenseKey, userID: "showcases-app-user", baseURL: baseURL)
  } else {
    .init(license: secrets.licenseKey, userID: "showcases-app-user")
  }
}

extension View {
  @MainActor
  func customEditorConfiguration(scene url: URL) -> some View {
    imgly.onCreate { engine in
      try await OnCreate.loadScene(from: url)(engine)
      try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
    }
    .imgly.assetLibrary {
      DefaultAssetLibrary()
        .images {
          AssetLibrarySource.image(.title("Unsplash"), source: .init(id: UnsplashAssetSource.id))
          DefaultAssetLibrary.images
        }
    }
  }
}
