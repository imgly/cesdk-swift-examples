// highlight-customAssetLibrary
import IMGLYEditor
import SwiftUI

@MainActor
struct CustomAssetLibrary: AssetLibrary {
  @Environment(\.imglyAssetLibrarySceneMode) var sceneMode
  // highlight-customAssetLibrary

  // highlight-assetLibraryBuilder
  @AssetLibraryBuilder var uploads: AssetLibraryContent {
    AssetLibrarySource.imageUpload(.title("Images"), source: .init(demoSource: .imageUpload))
    if sceneMode == .video {
      AssetLibrarySource.videoUpload(.title("Videos"), source: .init(demoSource: .videoUpload))
    }
  }

  @AssetLibraryBuilder var videosAndImages: AssetLibraryContent {
    AssetLibraryGroup.video("Videos") { videos }
    AssetLibraryGroup.image("Images") { images }
    AssetLibraryGroup.upload("Photo Roll") {
      AssetLibrarySource.imageUpload(.title("Images"), source: .init(demoSource: .imageUpload))
      AssetLibrarySource.videoUpload(.title("Videos"), source: .init(demoSource: .videoUpload))
    }
  }

  @AssetLibraryBuilder var videos: AssetLibraryContent {
    AssetLibrarySource.video(.title("Videos"), source: .init(demoSource: .video))
    AssetLibrarySource.videoUpload(.title("Photo Roll"), source: .init(demoSource: .videoUpload))
  }

  @AssetLibraryBuilder var audio: AssetLibraryContent {
    AssetLibrarySource.audio(.title("Audio"), source: .init(demoSource: .audio))
    AssetLibrarySource.audioUpload(.title("Uploads"), source: .init(demoSource: .audioUpload))
  }

  @AssetLibraryBuilder var images: AssetLibraryContent {
    AssetLibrarySource.image(.title("Unsplash"), source: .init(id: UnsplashAssetSource.id))
    AssetLibrarySource.image(.title("Images"), source: .init(demoSource: .image))
    AssetLibrarySource.imageUpload(.title("Photo Roll"), source: .init(demoSource: .imageUpload))
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
    AssetLibraryGroup.upload("Photo Roll") { uploads }
    if sceneMode == .video {
      AssetLibraryGroup.video("Videos") { videos }
      AssetLibraryGroup.audio("Audio") { audio }
    }
    AssetLibraryGroup.image("Images") { images }
    text
    AssetLibraryGroup.shape("Shapes") { shapes }
    AssetLibraryGroup.sticker("Stickers") { stickers }
  }

  // highlight-assetLibraryBuilder

  // highlight-assetLibraryView
  @ViewBuilder var uploadsTab: some View {
    AssetLibraryTab("Photo Roll") { uploads } label: { DefaultAssetLibrary.uploadsLabel($0) }
  }

  // highlight-assetLibraryTabViews
  @ViewBuilder var elementsTab: some View {
    AssetLibraryTab("Elements") { elements } label: { DefaultAssetLibrary.elementsLabel($0) }
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

  // highlight-assetLibraryTabViews

  // highlight-assetLibraryVideoEditor
  @ViewBuilder public var clipsTab: some View {
    AssetLibraryTab("Clips") { videosAndImages } label: { _ in EmptyView() }
  }

  @ViewBuilder public var overlaysTab: some View {
    AssetLibraryTab("Overlays") { videosAndImages } label: { _ in EmptyView() }
  }

  @ViewBuilder public var stickersAndShapesTab: some View {
    AssetLibraryTab("Stickers") {
      stickers
      shapes
    } label: { _ in EmptyView() }
  }

  // highlight-assetLibraryVideoEditor
  // highlight-assetLibraryView

  // highlight-assetLibraryTabView
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
  // highlight-assetLibraryTabView
}
