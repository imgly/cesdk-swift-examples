import AVFoundation
import IMGLYCore
import IMGLYEngine
import UIKit

@MainActor
public protocol AssetLibraryInteractor: ObservableObject {
  var isAddingAsset: Bool { get }
  func findAssets(sourceID: String, query: AssetQueryData) async throws -> AssetQueryResult
  func getGroups(sourceID: String) async throws -> [String]
  func getCredits(sourceID: String) -> AssetCredits?
  func getLicense(sourceID: String) -> AssetLicense?
  func addAsset(to sourceID: String, asset: AssetDefinition) throws

  func uploadAsset(to sourceID: String, asset: AssetUpload) async throws -> AssetResult
  func assetTapped(sourceID: String, asset: AssetResult)
  func getBasePath() throws -> String

  typealias AssetUpload = () throws -> (URL, blockType: String)
}

public extension AssetLibraryInteractor {
  func uploadImage(to sourceID: String, url: () throws -> URL) async throws -> AssetResult {
    try await uploadAsset(to: sourceID) {
      try (url(), blockType: DesignBlockType.image.rawValue)
    }
  }

  func uploadVideo(to sourceID: String, url: () throws -> URL) async throws -> AssetResult {
    try await uploadAsset(to: sourceID) {
      try (url(), blockType: "//ly.img.ubq/fill/video")
    }
  }

  func uploadAudio(to sourceID: String, url: () throws -> URL) async throws -> AssetResult {
    try await uploadAsset(to: sourceID) {
      try (url(), blockType: DesignBlockType.audio.rawValue)
    }
  }

  func uploadAsset(to sourceID: String, asset: AssetUpload) async throws -> AssetResult {
    try await Self.uploadAsset(interactor: self, to: sourceID, asset: asset)
  }

  static func uploadAsset(interactor: any AssetLibraryInteractor,
                          to sourceID: String, asset: AssetUpload) async throws -> AssetResult {
    let (url, blockType) = try asset()
    let meta = try await getMeta(url: url, blockType: blockType)
    let assetID = url.absoluteString
    try interactor.addAsset(to: sourceID, asset: .init(id: assetID, meta: meta))

    let result = try await interactor.findAssets(
      sourceID: sourceID,
      query: .init(query: assetID, page: 0, perPage: 10)
    )
    guard result.assets.count == 1, let asset = result.assets.first else {
      throw Error(errorDescription: "Could not retrieve uploaded asset.")
    }
    NotificationCenter.default.post(name: .AssetSourceDidChange, object: nil, userInfo: ["sourceID": sourceID])

    return asset
  }
}

private extension AssetLibraryInteractor {
  static func getMeta(url: URL, thumbURL: URL? = nil, blockType: String) async throws -> AssetMeta {
    switch blockType {
    case DesignBlockType.image.rawValue, DesignBlockType.video.rawValue, "//ly.img.ubq/fill/video":
      let (size, thumbURL) = try await getSizeAndThumb(url: url, thumbURL: thumbURL, blockType: blockType)
      return [
        .uri: url.absoluteString,
        .thumbUri: thumbURL.absoluteString,
        .blockType: blockType,
        .width: String(Int(size.width)),
        .height: String(Int(size.height))
      ]

    case DesignBlockType.audio.rawValue:
      let asset = AVURLAsset(url: url)
      var meta: AssetMeta = [
        .uri: url.absoluteString,
        .blockType: blockType,
        .duration: String(asset.duration.seconds)
      ]

      let metadata = asset.commonMetadata
      func parse(key: AVMetadataKey) -> AVMetadataItem? {
        AVMetadataItem.metadataItems(from: metadata, withKey: key, keySpace: AVMetadataKeySpace.common).first
      }
      let title = parse(key: .commonKeyTitle)?.stringValue
      let artist = parse(key: .commonKeyArtist)?.stringValue
      let artwork = parse(key: .commonKeyArtwork)?.dataValue

      if let title {
        meta[.title] = title
      }
      if let artist {
        meta[.artist] = artist
      }
      if let artwork, let image = UIImage(data: artwork) {
        let data = image.jpegData(compressionQuality: 1)
        guard let data else {
          throw Error(errorDescription: "Could not save artwork thumbnail to data.")
        }
        let thumbURL = try data.writeToUniqueCacheURL(for: .jpeg)
        meta[.thumbUri] = thumbURL.absoluteString
      }
      return meta
    default:
      throw Error(errorDescription: "Unsupported block type for upload.")
    }
  }

  static func getSizeAndThumb(url: URL, thumbURL: URL?, blockType: String) async throws -> (CGSize, URL) {
    switch blockType {
    case DesignBlockType.image.rawValue:
      let (data, _) = try await URLSession.get(url)
      guard let image = UIImage(data: data) else {
        throw Error(errorDescription: "Unsupported image data.")
      }
      return (image.size, thumbURL ?? url)

    case DesignBlockType.video.rawValue, "//ly.img.ubq/fill/video":
      let asset = AVURLAsset(url: url)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      imageGenerator.appliesPreferredTrackTransform = true
      let result = try await imageGenerator.generateImage(at: .zero)
      let image = UIImage(cgImage: result.image)
      if let thumbURL {
        return (image.size, thumbURL)
      } else {
        let data = image.jpegData(compressionQuality: 1)
        guard let data else {
          throw Error(errorDescription: "Could not save video thumbnail to data.")
        }
        let thumbURL = try data.writeToUniqueCacheURL(for: .jpeg)
        return (image.size, thumbURL)
      }
    default:
      throw Error(errorDescription: "Unsupported block type for upload.")
    }
  }
}
