import Foundation
import IMGLYEngine

extension AssetResult {
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
}
