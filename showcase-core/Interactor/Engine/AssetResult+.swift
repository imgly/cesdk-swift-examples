import Foundation
import IMGLYEngine

public extension AssetResult {
  var thumbURL: URL? {
    guard let string = meta?["thumbUri"] else {
      return nil
    }
    return URL(string: string)
  }

  var url: URL? {
    guard let string = meta?["uri"] else {
      return nil
    }
    return URL(string: string)
  }

  var thumbURLorURL: URL? {
    thumbURL ?? url
  }
}

extension AssetResult: Identifiable {}
