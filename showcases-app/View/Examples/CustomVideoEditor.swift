import IMGLYEditor
import SwiftUI

struct CustomVideoEditor: View {
  @State private var remoteAssetSources = [RemoteAssetSource.Path: String]()

  var body: some View {
    let url = Bundle.main.url(forResource: "monthly-review", withExtension: "scene")!
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await VideoEditorConfiguration.defaultOnCreate(createScene: { engine in
              try await OnCreate.loadScene(from: url)(engine)

              if !secrets.remoteAssetSourceHost.isEmpty {
                remoteAssetSources = try await engine.addRemoteAssetSources(host: secrets.remoteAssetSourceHost)
              }
            })(engine)
          }
          builder.assetLibrary { al in
            al.modify { categories in
              categories.modifySections(of: AssetLibraryCategory.ID.videos) { sections in
                if let id = remoteAssetSources[.videoGiphy] {
                  sections.addFirst(.video(id: id, title: "Giphy", source: .init(id: id)))
                }
                if let id = remoteAssetSources[.videoPexels] {
                  sections.addFirst(.video(id: id, title: "Pexels", source: .init(id: id)))
                }
              }
              categories.modifySections(of: AssetLibraryCategory.ID.images) { sections in
                if let id = remoteAssetSources[.imageUnsplash] {
                  sections.addFirst(.image(id: id, title: "Unsplash", source: .init(id: id)))
                }
                if let id = remoteAssetSources[.imagePexels] {
                  sections.addFirst(.image(id: id, title: "Pexels", source: .init(id: id)))
                }
              }
              categories.modifySections(of: AssetLibraryCategory.ID.stickers) { sections in
                if let id = remoteAssetSources[.videoGiphySticker] {
                  sections.addFirst(.sticker(id: id, title: "Giphy Stickers", source: .init(id: id)))
                }
              }
            }
          }
        }
        ShowcasesEditorConfiguration()
      }
  }
}
