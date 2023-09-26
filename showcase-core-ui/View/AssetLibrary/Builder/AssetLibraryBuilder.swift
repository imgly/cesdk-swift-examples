import SwiftUI

@MainActor
@resultBuilder
public enum AssetLibraryBuilder {
  public static func buildBlock(_ components: AssetLibraryContent...) -> AssetLibraryContent {
    let flattenUnnamedGroups = components.flatMap { component in
      if let group = component as? AssetLibraryGroup<EmptyView> {
        return group.components
      } else {
        return [component]
      }
    }
    return AssetLibraryGroup<EmptyView>(components: flattenUnnamedGroups)
  }

  public static func buildOptional(_ component: AssetLibraryContent?) -> AssetLibraryContent {
    if let component {
      return AssetLibraryGroup<EmptyView>(components: [component])
    } else {
      return AssetLibraryGroup<EmptyView>(components: [])
    }
  }

  public static func buildEither(first component: AssetLibraryContent) -> AssetLibraryContent {
    AssetLibraryGroup<EmptyView>(components: [component])
  }

  public static func buildEither(second component: AssetLibraryContent) -> AssetLibraryContent {
    AssetLibraryGroup<EmptyView>(components: [component])
  }
}

struct AssetLibraryBuilder_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
