import IMGLYCore
import SwiftUI
import SwiftUIBackports
import UniformTypeIdentifiers

// MARK: - Public interface

public extension View {
  func nonDefaultPreviewSettings() -> some View {
    previewDisplayName("Landscape, dark mode, RTL")
      .previewInterfaceOrientation(.landscapeRight)
      .preferredColorScheme(.dark)
      .environment(\.layoutDirection, .rightToLeft)
  }

  @MainActor
  func assetLibraryInteractor(_ interactor: some AssetLibraryInteractor) -> some View {
    environmentObject(AnyAssetLibraryInteractor(erasing: interactor))
  }

  func assetLibraryDismissButton(_ content: some View) -> some View {
    environment(\.dismissButtonView, DismissButton(content: AnyView(erasing: content)))
  }

  func assetLibraryTitleDisplayMode(_ mode: NavigationBarItem.TitleDisplayMode) -> some View {
    environment(\.assetLibraryTitleDisplayMode, mode)
  }

  func assetLibrary(sources: [AssetLoader.SourceData]) -> some View { environment(\.assetLibrarySources, sources) }

  /// Automatically passes the sources and search query to the `AssetLoader` from the environment.
  @MainActor
  func assetLoader() -> some View {
    modifier(SearchedAssetLoader())
  }

  @MainActor
  func assetLoader(
    sources: [AssetLoader.SourceData],
    search: Binding<AssetLoader.QueryData> = .constant(.init()),
    order: AssetLoader.ItemOrder = .alternating,
    perPage: Int = 30
  ) -> some View {
    modifier(AssetLoader(sources: sources, search: search, order: order, perPage: perPage))
  }

  func assetGrid(axis: Axis) -> some View { environment(\.assetGridAxis, axis) }
  func assetGrid(items: [GridItem]) -> some View { environment(\.assetGridItems, items) }
  func assetGrid(spacing: CGFloat?) -> some View { environment(\.assetGridSpacing, spacing) }
  func assetGrid(edges: Edge.Set) -> some View { environment(\.assetGridEdges, edges) }
  func assetGrid(padding: CGFloat?) -> some View { environment(\.assetGridPadding, padding) }
  func assetGrid(messageTextOnly: Bool) -> some View { environment(\.assetGridMessageTextOnly, messageTextOnly) }
  func assetGrid(maxItemCount: Int) -> some View { environment(\.assetGridMaxItemCount, maxItemCount) }
  func assetGridPlaceholderCount(_ placeholderCount: @escaping AssetGridPlaceholderCount)
    -> some View { environment(\.assetGridPlaceholderCount, placeholderCount) }
  func assetGrid(sourcePadding: CGFloat) -> some View { environment(\.assetGridSourcePadding, sourcePadding) }
  func assetGridItemIndex(_ itemIndex: @escaping AssetGridItemIndex)
    -> some View { environment(\.assetGridItemIndex, itemIndex) }
  func assetGridOnAppear(_ onAppear: @escaping AssetGridOnAppear)
    -> some View { environment(\.assetGridOnAppear, onAppear) }

  @ViewBuilder
  func conditionalPresentationDragIndicator(_ visibility: Visibility) -> some View {
    if #available(iOS 16.0, *) {
      presentationDragIndicator(visibility)
    } else {
      backport.presentationDragIndicator({
        switch visibility {
        case .automatic: return .automatic
        case .visible: return .visible
        case .hidden: return .hidden
        }
      }())
    }
  }
}

extension View {
  @MainActor
  func searchableAssetLibraryTab() -> some View {
    modifier(SearchableAssetLibraryTab())
  }

  func assetFileUploader(isPresented: Binding<Bool>, allowedContentTypes: [UTType],
                         onCompletion: @escaping AssetFileUploader.Completion = { _ in }) -> some View {
    modifier(AssetFileUploader(isPresented: isPresented, allowedContentTypes: allowedContentTypes,
                               onCompletion: onCompletion))
  }

  func shimmer() -> some View {
    modifier(Shimmer())
  }

  func inverseMask(alignment: Alignment = .center, @ViewBuilder _ mask: () -> some View) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }

  func onReceive(
    _ name: Notification.Name,
    center: NotificationCenter = .default,
    object: AnyObject? = nil,
    perform action: @escaping (Notification) -> Void
  ) -> some View {
    onReceive(center.publisher(for: name, object: object), perform: action)
  }

  func delayedGesture(_ gesture: some Gesture, with delay: TimeInterval = 0.2) -> some View {
    modifier(DelayedGesture(duration: delay, gesture: gesture))
  }
}
