import IMGLYEditor
import SwiftUI

@MainActor
struct CustomAssetLibrary: AssetLibrary {
  @Environment(\.imglyAssetLibrarySceneMode) var sceneMode

  @AssetLibraryBuilder var uploads: AssetLibraryContent {
    AssetLibrarySource.imageUpload(.title("Images"), source: .init(demoSource: .imageUpload))
    if sceneMode == .video {
      AssetLibrarySource.videoUpload(.title("Videos"), source: .init(demoSource: .videoUpload))
    }
  }

  @AssetLibraryBuilder var videos: AssetLibraryContent {
    AssetLibrarySource.videoUpload(.title("Camera Roll"), source: .init(demoSource: .videoUpload))
    AssetLibrarySource.video(.title("Videos"), source: .init(demoSource: .video))
  }

  @AssetLibraryBuilder var audio: AssetLibraryContent {
    AssetLibrarySource.audioUpload(.title("Uploads"), source: .init(demoSource: .audioUpload))
    AssetLibrarySource.audio(.title("Audio"), source: .init(demoSource: .audio))
  }

  @AssetLibraryBuilder var images: AssetLibraryContent {
    AssetLibrarySource.imageUpload(.title("Camera Roll"), source: .init(demoSource: .imageUpload))
    AssetLibrarySource.image(.title("Images"), source: .init(demoSource: .image))
  }

  let text = AssetLibrarySource.text(.title("Text"), source: .init(id: TextAssetSource.id))

  @AssetLibraryBuilder var shapes: AssetLibraryContent {
    AssetLibrarySource.shape(.title("Basic"), source: .init(
      defaultSource: .vectorPath, config: .init(groups: ["//ly.img.cesdk.vectorpaths/category/vectorpaths"])))
    AssetLibrarySource.shape(.title("Abstract"), source: .init(
      defaultSource: .vectorPath, config: .init(groups: ["//ly.img.cesdk.vectorpaths.abstract/category/abstract"])))
  }

  @AssetLibraryBuilder var stickers: AssetLibraryContent {
    AssetLibrarySource.sticker(.titleForGroup { group in
      if let name = group?.split(separator: "/").last {
        return name.capitalized
      } else {
        return "Stickers"
      }
    }, source: .init(defaultSource: .sticker))
  }

  @AssetLibraryBuilder var elements: AssetLibraryContent {
    AssetLibraryGroup.upload("Camera Roll") { uploads }
    if sceneMode == .video {
      AssetLibraryGroup.video("Videos") { videos }
      AssetLibraryGroup.audio("Audio") { audio }
    }
    AssetLibraryGroup.image("Images") { images }
    text
    AssetLibraryGroup.shape("Shapes") { shapes }
    AssetLibraryGroup.sticker("Stickers") { stickers }
  }

  @ViewBuilder var elementsTab: some View {
    AssetLibraryTab("Elements") { elements } label: { DefaultAssetLibrary.elementsLabel($0) }
  }

  @ViewBuilder var uploadsTab: some View {
    AssetLibraryTab("Camera Roll") { uploads } label: { DefaultAssetLibrary.uploadsLabel($0) }
  }

  @ViewBuilder var videosTab: some View {
    AssetLibraryTab("Videos") { videos } label: { DefaultAssetLibrary.videosLabel($0) }
  }

  @ViewBuilder var audioTab: some View {
    AssetLibraryTab("Audio") { audio } label: { DefaultAssetLibrary.audioLabel($0) }
  }

  @ViewBuilder var imagesTab: some View {
    AssetLibraryTab("Images") { images } label: { DefaultAssetLibrary.imagesLabel($0) }
  }

  @ViewBuilder var textTab: some View {
    AssetLibraryTabView("Text") { text.content } label: { DefaultAssetLibrary.textLabel($0) }
  }

  @ViewBuilder var shapesTab: some View {
    AssetLibraryTab("Shapes") { shapes } label: { DefaultAssetLibrary.shapesLabel($0) }
  }

  @ViewBuilder var stickersTab: some View {
    AssetLibraryTab("Stickers") { stickers } label: { DefaultAssetLibrary.stickersLabel($0) }
  }

  var body: some View {
    TabView {
      if sceneMode == .video {
        elementsTab
        uploadsTab
        videosTab
        audioTab
        AssetLibraryMoreTab {
          imagesTab
          textTab
          shapesTab
          stickersTab
        }
      } else {
        elementsTab
        imagesTab
        textTab
        shapesTab
        stickersTab
      }
    }
  }
}
