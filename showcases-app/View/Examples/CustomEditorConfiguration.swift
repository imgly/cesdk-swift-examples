import IMGLYEditor
import SwiftUI

let settings = EngineSettings(license: secrets.licenseKey, userID: "showcases-app-user")

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
