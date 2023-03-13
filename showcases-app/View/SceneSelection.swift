import IMGLYApparelUI
import IMGLYEditorUI
import IMGLYPostcardUI
import SwiftUI

@MainActor
protocol ShowcaseUI: View {
  init(scene: URL)
}

extension ApparelUI: ShowcaseUI {}
extension PostcardUI: ShowcaseUI {}

extension SceneSelection.Scene {
  init(_ resource: String, title: LocalizedStringKey, colorPalette: [NamedColor]? = nil) {
    self.title = title
    url = Bundle.main.url(forResource: resource, withExtension: "scene")!
    image = Bundle.main.url(forResource: resource, withExtension: "png")!
    self.colorPalette = colorPalette
  }
}

struct SceneSelection<Content: ShowcaseUI>: View {
  struct Scene: Identifiable {
    var id: URL { url }
    /// Scene title.
    let title: LocalizedStringKey
    /// Scene file.
    let url: URL
    /// Preview image.
    let image: URL
    /// Custom color palette.
    let colorPalette: [NamedColor]?
  }

  private let scenes: [Scene]

  init(scenes: [(title: String, colorPalette: [(name: LocalizedStringKey, color: CGColor)]?)]) {
    self.scenes = scenes.map {
      let resource = $0.title.replacingOccurrences(of: " ", with: "_").lowercased()
      return .init(resource, title: LocalizedStringKey($0.title),
                   colorPalette: $0.colorPalette?.map { .init($0.name, $0.color) })
    }
  }

  var body: some View {
    let shadowColor = Color(red: 0.09, green: 0.09, blue: 0.09)
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 16)], spacing: 16) {
        ForEach(scenes) { scene in
          NavigationLink {
            Content(scene: scene.url)
              .colorPalette(scene.colorPalette)
          } label: {
            AsyncImage(url: scene.image) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .shadow(color: shadowColor.opacity(0.12), radius: 3.5, y: 2)
                .shadow(color: shadowColor.opacity(0.12), radius: 5, y: 4)
                .shadow(color: shadowColor.opacity(0.12), radius: 12, y: 8)
                .shadow(color: shadowColor.opacity(0.25), radius: 2)
                .accessibilityLabel(scene.title)
            } placeholder: {
              ProgressView()
            }
          }
        }
      }
      .padding(16)
    }
    .background {
      Color(uiColor: .secondarySystemBackground)
        .ignoresSafeArea()
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Choose Template")
  }
}
