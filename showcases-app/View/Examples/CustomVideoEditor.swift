import IMGLYVideoEditor
import SwiftUI

struct CustomVideoEditor: View {
  @State private var remoteAssetSources = [RemoteAssetSource.Path: String]()

  var body: some View {
    let url = Bundle.main.url(forResource: "monthly-review", withExtension: "scene")!
    VideoEditor(settings)
      .imgly.onCreate { engine in
        try await OnCreate.loadScene(from: url)(engine)

        if !secrets.remoteAssetSourceHost.isEmpty {
          remoteAssetSources = try await engine.addRemoteAssetSources(host: secrets.remoteAssetSourceHost)
        }
      }
      .imgly.assetLibrary {
        DefaultAssetLibrary()
          .videos {
            if let id = remoteAssetSources[.videoPexels] {
              AssetLibrarySource.image(.title("Pexels"), source: .init(id: id))
            }
            if let id = remoteAssetSources[.videoGiphy] {
              AssetLibrarySource.image(.title("Giphy"), source: .init(id: id))
            }
            DefaultAssetLibrary.videos
          }
          .images {
            if let id = remoteAssetSources[.imagePexels] {
              AssetLibrarySource.image(.title("Pexels"), source: .init(id: id))
            }
            if let id = remoteAssetSources[.imageUnsplash] {
              AssetLibrarySource.image(.title("Unsplash"), source: .init(id: id))
            }
            DefaultAssetLibrary.images
          }
          .stickers {
            if let id = remoteAssetSources[.videoGiphySticker] {
              AssetLibrarySource.sticker(.title("Giphy Stickers"), source: .init(id: id))
            }
            DefaultAssetLibrary.stickers
          }
      }
  }
}
