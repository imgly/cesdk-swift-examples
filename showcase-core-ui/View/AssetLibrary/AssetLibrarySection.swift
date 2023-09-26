import SwiftUI

public struct AssetLibrarySection<Destination: View, Preview: View, Accessory: View>: View {
  private let title: String
  @ViewBuilder private let destination: () -> Destination
  @ViewBuilder private let preview: () -> Preview
  @ViewBuilder private let accessory: () -> Accessory

  public init(_ title: String,
              @ViewBuilder destination: @escaping () -> Destination,
              @ViewBuilder preview: @escaping () -> Preview,
              @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }) {
    self.title = title
    self.destination = destination
    self.preview = preview
    self.accessory = accessory
  }

  var localizedTitle: LocalizedStringKey { .init(title) }

  @State var totalResults: Int?
  @Environment(\.dismissButtonView) private var dismissButtonView
  @EnvironmentObject private var searchState: AssetLibrary.SearchState

  @ViewBuilder var label: some View {
    if let totalResults {
      if totalResults < 0 || totalResults > 999 {
        Text("More")
      } else {
        Text("\(totalResults)")
      }
    }
    Image(systemName: "chevron.forward")
  }

  @MainActor
  @ViewBuilder var content: some View {
    destination()
      .navigationTitle(localizedTitle)
      .toolbar {
        ToolbarItem {
          HStack {
            SearchButton()
            dismissButtonView
          }
        }
      }
      .onAppear {
        searchState.setPrompt(for: title)
      }
  }

  public var body: some View {
    Section {
      preview()
        .environment(\.seeAllView, SeeAll(destination: AnyView(erasing: content)))
        .onPreferenceChange(AssetLoader.TotalResultsKey.self) { newValue in
          totalResults = newValue
        }
    } header: {
      HStack(spacing: 26) {
        Text(localizedTitle)
          .font(.headline)
        Spacer()
        accessory()
          .font(.subheadline)
        NavigationLink {
          content
        } label: {
          label
            .font(.subheadline.weight(.semibold).monospacedDigit())
            .accessibilityLabel(.init("More \(title)"))
        }
      }
      .padding(.top, 16)
      .padding([.leading, .trailing], 16)
    }
  }
}

struct AssetLibrarySeeAllKey: EnvironmentKey {
  static let defaultValue: SeeAll? = nil
}

extension EnvironmentValues {
  var seeAllView: SeeAll? {
    get { self[AssetLibrarySeeAllKey.self] }
    set { self[AssetLibrarySeeAllKey.self] = newValue }
  }
}

struct SeeAll: View {
  let destination: AnyView

  var body: some View {
    NavigationLink {
      destination
    } label: {
      VStack(spacing: 4) {
        ZStack {
          Image(systemName: "arrow.forward")
            .font(.title2)
          Circle()
            .stroke()
            .frame(width: 48, height: 48)
            .foregroundColor(.secondary)
        }
        Text("See All")
          .font(.caption.weight(.medium))
      }
      .foregroundColor(.primary)
    }
  }
}

struct AssetLibraryDismissButtonKey: EnvironmentKey {
  static let defaultValue: DismissButton? = nil
}

extension EnvironmentValues {
  var dismissButtonView: DismissButton? {
    get { self[AssetLibraryDismissButtonKey.self] }
    set { self[AssetLibraryDismissButtonKey.self] = newValue }
  }
}

struct DismissButton: View {
  let content: AnyView

  public var body: some View {
    content
  }
}

struct AssetLibrarySection_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
