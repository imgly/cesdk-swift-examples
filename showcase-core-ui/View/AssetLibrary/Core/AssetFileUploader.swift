import IMGLYCore
import IMGLYEngine
import Media
import SwiftUI

struct AssetFileUploader: ViewModifier {
  @Environment(\.assetLibrarySources) private var sources
  @EnvironmentObject private var interactor: AnyAssetLibraryInteractor

  @Binding var isPresented: Bool
  let allowedContentTypes: [UTType]
  typealias Completion = (Result<AssetResult, Swift.Error>) -> Void
  let onCompletion: Completion

  func body(content: Content) -> some View {
    content
      .fileImporter(isPresented: $isPresented, allowedContentTypes: allowedContentTypes) { result in
        guard let source = sources.first else {
          return
        }
        Task {
          do {
            let asset = try await interactor.uploadAsset(to: source.id) {
              let securityScopedURL = try result.get()
              guard securityScopedURL.startAccessingSecurityScopedResource() else {
                throw Error(errorDescription: "Could not access security scoped resource.")
              }
              defer { securityScopedURL.stopAccessingSecurityScopedResource() }
              let url = try FileManager.default.getUniqueCacheURL()
                .appendingPathExtension(securityScopedURL.pathExtension)
              try FileManager.default.copyItem(at: securityScopedURL, to: url)

              let contentType: UTType
              do {
                contentType = try url.contentType()
              } catch {
                guard allowedContentTypes.count == 1,
                      let allowedContentType = allowedContentTypes.first else {
                  throw Error(errorDescription: "Could not determine content type.")
                }
                contentType = allowedContentType
              }

              return try (url, blockType: contentType.blockType())
            }
            onCompletion(.success(asset))
          } catch {
            onCompletion(.failure(error))
          }
        }
      }
  }
}

private extension URL {
  func contentType() throws -> UTType {
    guard let contentType = try resourceValues(forKeys: [.contentTypeKey]).contentType else {
      throw Error(errorDescription: "Could not access content type resource value.")
    }
    return contentType
  }
}

private extension UTType {
  func blockType() throws -> String {
    if conforms(to: .video) {
      return "//ly.img.ubq/fill/video"
    } else if conforms(to: .audio) {
      return DesignBlockType.audio.rawValue
    } else if conforms(to: .image) {
      return DesignBlockType.image.rawValue
    }
    throw Error(errorDescription: "Unsupported content type to block type mapping.")
  }
}

struct AssetFileUploader_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
