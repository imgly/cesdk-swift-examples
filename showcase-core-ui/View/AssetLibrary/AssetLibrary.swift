import IMGLYCore
import IMGLYEngine
import SwiftUI

@MainActor
public struct AssetLibrary: View {
  public init(sceneMode: SceneMode) {
    self.sceneMode = sceneMode
  }

  let sceneMode: SceneMode

  let imageUploadSourceID = "ly.img.image.upload"
  let videoUploadSourceID = "ly.img.video.upload"
  let audioUploadSourceID = "ly.img.audio.upload"
  let shapeSourceID = "ly.img.vectorpath"

  @AssetLibraryBuilder var uploads: AssetLibraryContent {
    AssetLibrarySource.imageUpload(.title("Images"), source: .init(id: imageUploadSourceID))
    if sceneMode == .video {
      AssetLibrarySource.videoUpload(.title("Videos"), source: .init(id: videoUploadSourceID))
    }
  }

  @AssetLibraryBuilder var videos: AssetLibraryContent {
    AssetLibrarySource.videoUpload(.title("Camera Roll"), source: .init(id: videoUploadSourceID))
    AssetLibrarySource.video(.title("Videos"), source: .init(id: "ly.img.video"))
  }

  @AssetLibraryBuilder var audio: AssetLibraryContent {
    AssetLibrarySource.audioUpload(.title("Uploads"), source: .init(id: audioUploadSourceID))
    AssetLibrarySource.audio(.title("Audio"), source: .init(id: "ly.img.audio"))
  }

  @AssetLibraryBuilder var images: AssetLibraryContent {
    AssetLibrarySource.imageUpload(.title("Camera Roll"), source: .init(id: imageUploadSourceID))
    AssetLibrarySource.image(.title("Images"), source: .init(id: "ly.img.image"))
    AssetLibrarySource.image(.title("Unsplash"), source: .init(id: UnsplashAssetSource.id))
  }

  @AssetLibraryBuilder var shapes: AssetLibraryContent {
    AssetLibrarySource.shape(.title("Basic"), source: .init(
      id: shapeSourceID, config: .init(groups: ["//ly.img.cesdk.vectorpaths/category/vectorpaths"])))
    AssetLibrarySource.shape(.title("Abstract"), source: .init(
      id: shapeSourceID, config: .init(groups: ["//ly.img.cesdk.vectorpaths.abstract/category/abstract"])))
  }

  let text = AssetLibrarySource.text(.title("Text"), source: .init(id: TextAssetSource.id))

  @AssetLibraryBuilder var stickers: AssetLibraryContent {
    AssetLibrarySource.sticker(.titleForGroup { group in
      if let name = group?.split(separator: "/").last {
        return name.capitalized
      } else {
        return "Stickers"
      }
    }, source: .init(id: "ly.img.sticker"))
  }

  @ViewBuilder public static func elementsLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "books.vertical")
  }

  @ViewBuilder public static func uploadsLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "camera")
  }

  @ViewBuilder public static func videosLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "play.rectangle")
  }

  @ViewBuilder public static func audioLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "music.note.list")
  }

  @ViewBuilder public static func imagesLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "photo")
  }

  @ViewBuilder public static func textLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "textformat.alt")
  }

  @ViewBuilder public static func shapesLabel(_ title: LocalizedStringKey) -> some View {
    Label(title, systemImage: "square.on.circle")
  }

  @ViewBuilder public static func stickersLabel(_ title: LocalizedStringKey) -> some View {
    if #available(iOS 16.0, *) {
      // Fixes light/dark mode fill issue.
      Label {
        Text(title)
      } icon: {
        Image("custom.face.smiling", bundle: Bundle.bundle)
      }
    } else {
      Label(title, systemImage: "face.smiling")
    }
  }

  @ViewBuilder public var elementsTab: some View {
    AssetLibraryTab("Elements") {
      AssetLibraryGroup.upload("Camera Roll") { uploads }
      if sceneMode == .video {
        AssetLibraryGroup.video("Videos") { videos }
        AssetLibraryGroup.audio("Audio") { audio }
      }
      AssetLibraryGroup.image("Images") { images }
      text
      AssetLibraryGroup.shape("Shapes") { shapes }
      AssetLibraryGroup.sticker("Stickers") { stickers }
    } label: { Self.elementsLabel($0) }
  }

  @ViewBuilder public var uploadsTab: some View {
    AssetLibraryTab("Camera Roll") { uploads } label: { Self.uploadsLabel($0) }
  }

  @ViewBuilder public var videosTab: some View {
    AssetLibraryTab("Videos") { videos } label: { Self.videosLabel($0) }
  }

  @ViewBuilder public var audioTab: some View {
    AssetLibraryTab("Audio") { audio } label: { Self.audioLabel($0) }
  }

  @ViewBuilder public var imagesTab: some View {
    AssetLibraryTab("Images") { images } label: { Self.imagesLabel($0) }
  }

  @ViewBuilder public var textTab: some View {
    AssetLibraryTabView("Text") { text.content } label: { Self.textLabel($0) }
  }

  @ViewBuilder public var shapesTab: some View {
    AssetLibraryTab("Shapes") { shapes } label: { Self.shapesLabel($0) }
  }

  @ViewBuilder public var stickersTab: some View {
    AssetLibraryTab("Stickers") { stickers } label: { Self.stickersLabel($0) }
  }

  @State var selectedTab: String = "Elements"

  public var body: some View {
    TabView(selection: $selectedTab) {
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

extension AssetLibrary {
  class SearchState: ObservableObject {
    @Published public var isPresented: Bool = false
    @Published public private(set) var prompt: Text?

    func setPrompt(for title: String) {
      prompt = .init(LocalizedStringKey("Search \(title)" + String.ellipsis))
    }
  }
}

public extension AssetLibrary {
  typealias SearchQuery = Debouncer<AssetLoader.QueryData>
}

public extension AssetLibrarySource<UploadGrid, AssetPreview, UploadButton> {
  static func imageUpload(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) {
      Destination(media: [.image])
    } preview: {
      Preview.imageOrVideo
    } accessory: {
      Accessory(media: [.image])
    }
  }

  static func videoUpload(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) {
      Destination(media: [.movie])
    } preview: {
      Preview.imageOrVideo
    } accessory: {
      Accessory(media: [.movie])
    }
  }
}

public extension AssetLibrarySource<AudioUploadGrid, AudioPreview, AudioUploadButton> {
  static func audioUpload(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) {
      Destination()
    } preview: {
      Preview()
    } accessory: {
      Accessory()
    }
  }
}

public extension AssetLibrarySource<ImageGrid<Message, EmptyView>, AssetPreview, EmptyView> {
  static func image(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview.imageOrVideo }
  }

  static func video(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview.imageOrVideo }
  }
}

public extension AssetLibrarySource<AudioGrid<Message, EmptyView>, AudioPreview, EmptyView> {
  static func audio(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview() }
  }
}

public extension AssetLibrarySource<TextGrid, TextPreview, EmptyView> {
  static func text(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview() }
  }
}

public extension AssetLibrarySource<ShapeGrid, AssetPreview, EmptyView> {
  static func shape(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview.shapeOrSticker }
  }
}

public extension AssetLibrarySource<StickerGrid, AssetPreview, EmptyView> {
  static func sticker(_ mode: Mode, source: AssetLoader.SourceData) -> Self {
    self.init(mode, source: source) { Destination() } preview: { Preview.shapeOrSticker }
  }
}

public extension AssetLibraryGroup<AssetPreview> {
  static func upload(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview.imageOrVideo }
  }

  static func image(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview.imageOrVideo }
  }

  static func video(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview.imageOrVideo }
  }

  static func shape(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview.shapeOrSticker }
  }

  static func sticker(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview.shapeOrSticker }
  }
}

public extension AssetLibraryGroup<AudioPreview> {
  static func audio(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview() }
  }
}

public extension AssetLibraryGroup<TextPreview> {
  static func text(_ title: String, @AssetLibraryBuilder content: () -> AssetLibraryContent) -> Self {
    self.init(title, content: content) { Preview() }
  }
}

public extension AssetPreview {
  static let imageOrVideo = Self(height: 96)
  static let shapeOrSticker = Self(height: 80)
}

struct AssetLibrary_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
