import IMGLYVideoEditor
import SwiftUI

struct CustomVideoEditor: View {
  @State private var remoteAssetSources = [RemoteAssetSource.Path: String]()
  private let stickerMiscID = "ly.img.sticker.misc"

  var body: some View {
    let url = Bundle.main.url(forResource: "monthly-review", withExtension: "scene")!
    VideoEditor(settings)
      .imgly.onCreate { engine in
        try await OnCreate.loadScene(from: url)(engine)

        if !secrets.remoteAssetSourceHost.isEmpty {
          remoteAssetSources = try await engine.addRemoteAssetSources(host: secrets.remoteAssetSourceHost)
        }

        let bundleURL = Bundle.main.url(forResource: "Assets", withExtension: "bundle")!
        let baseURL = bundleURL.appendingPathComponent(stickerMiscID)
        let jsonURL = baseURL.appendingPathComponent("content", conformingTo: .json)
        try await engine.populateAssetSource(id: stickerMiscID, jsonURL: jsonURL, replaceBaseURL: baseURL)
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
            AssetLibrarySource.sticker(.title("Hand"), source: .init(
              defaultSource: .sticker, config: .init(groups: ["//ly.img.cesdk.stickers.hand/category/hand"])))
            AssetLibrarySource.sticker(.titleForGroup { group in
              if let name = group {
                switch name {
                case "3dstickers": "3D Stickers"
                default: "\(name.capitalized)"
                }
              } else {
                "Stickers"
              }
            }, source: .init(id: stickerMiscID))
          }
      }
  }
}
