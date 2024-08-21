import Foundation

enum ImageSource: Labelable, IdentifiableByHash, CaseIterable {
  case uploads, images, unsplash

  var description: String {
    switch self {
    case .uploads: return "Uploads"
    case .images: return "Examples"
    case .unsplash: return "Unsplash"
    }
  }

  var imageName: String? { nil }

  @MainActor
  var sourceID: String {
    switch self {
    case .uploads: return "ly.img.image.upload"
    case .images: return "ly.img.image.showcase"
    case .unsplash: return UnsplashAssetSource.id
    }
  }
}
