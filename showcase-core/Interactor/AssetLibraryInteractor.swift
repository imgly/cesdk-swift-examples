import Foundation
import IMGLYEngine

@MainActor
public protocol AssetLibraryInteractor {
  var isAddingAsset: Bool { get }
  func findAssets(sourceID: String, query: AssetQueryData) async throws -> AssetQueryResult
  func assetTapped(sourceID: String, asset: AssetResult)
  func uploadAsset(sourceID: String, url: URL, thumb: URL, type: DesignBlockType)
}

public extension AssetLibraryInteractor {
  func uploadImage(sourceID: String, url: URL, thumb: URL? = nil) {
    uploadAsset(sourceID: sourceID, url: url, thumb: thumb ?? url, type: .image)
  }
}
