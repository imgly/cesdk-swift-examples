import IMGLYCore
import IMGLYEngine
import Kingfisher
import SwiftUI

struct ReloadableAsyncImage<Content: View>: View {
  @EnvironmentObject private var interactor: AnyAssetLibraryInteractor
  let asset: AssetLoader.Asset
  @ViewBuilder let content: (KFImage) -> Content

  @State private var state = LoadingState.loading

  @ViewBuilder private var background: some View {
    GridItemBackground()
      .aspectRatio(1, contentMode: .fit)
  }

  private enum LoadingState {
    case loading, error, loaded
  }

  var body: some View {
    ZStack {
      switch state {
      case .loading:
        background
          .shimmer()
      case .error:
        background
          .overlay {
            Image("custom.photo.badge.exclamationmark", bundle: Bundle.bundle)
              .imageScale(.large)
              .foregroundColor(.secondary)
          }
      case .loaded:
        background
      }

      if state != .error {
        content(
          KFImage(asset.thumbURLorURL)
            .retry(maxCount: 3)
            .onSuccess { _ in
              state = .loaded
            }
            .onFailure { _ in
              state = .error
            }
            .fade(duration: 0.15)
        )
        .onTapGesture {
          interactor.assetTapped(sourceID: asset.sourceID, asset: asset.result)
        }
        .allowsHitTesting(state == .loaded)
        .accessibilityLabel(asset.result.label ?? "")
      }
    }
  }
}

struct ReloadableAsyncImage_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
