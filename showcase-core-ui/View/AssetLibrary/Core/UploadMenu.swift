import IMGLYEngine
import Media
import SwiftUI

public struct UploadMenu<Label: View>: View {
  @Environment(\.assetLibrarySources) private var sources
  @EnvironmentObject private var interactor: AnyAssetLibraryInteractor
  private let media: [MediaType]

  @State private var showImagePicker = false
  @State private var showCamera = false
  @State private var showFileImporter = false

  @ViewBuilder private let label: () -> Label

  public init(media: [MediaType], @ViewBuilder label: @escaping () -> Label) {
    self.media = media
    self.label = label
  }

  var mediaCompletion: MediaCompletion {
    { result in
      guard let source = sources.first else {
        return
      }
      Task {
        try await interactor.uploadAsset(to: source.id) {
          let (url, media) = try result.get()
          switch media {
          case .image: return (url, blockType: DesignBlockType.image.rawValue)
          case .movie: return (url, blockType: "//ly.img.ubq/fill/video")
          }
        }
      }
    }
  }

  var mediaDescription: String {
    if media.contains(.image), media.contains(.movie) {
      return "Photo or Video"
    } else if media.contains(.image) {
      return "Photo"
    } else {
      return "Video"
    }
  }

  public var body: some View {
    Menu {
      Button {
        showImagePicker.toggle()
      } label: {
        SwiftUI.Label(LocalizedStringKey("Choose \(mediaDescription)"), systemImage: "photo.on.rectangle")
      }
      Button {
        showCamera.toggle()
      } label: {
        SwiftUI.Label(LocalizedStringKey("Take \(mediaDescription)"), systemImage: "camera")
      }
      Button {
        showFileImporter.toggle()
      } label: {
        SwiftUI.Label(LocalizedStringKey("Select \(mediaDescription)"), systemImage: "folder")
      }
    } label: {
      label()
    }
    .imagePicker(isPresented: $showImagePicker, media: media, onComplete: mediaCompletion)
    .camera(isPresented: $showCamera, media: media, onComplete: mediaCompletion)
    .assetFileUploader(isPresented: $showFileImporter, allowedContentTypes: media.map {
      switch $0 {
      case .image: return .image
      case .movie: return .video
      }
    })
  }
}

struct UploadMenu_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
