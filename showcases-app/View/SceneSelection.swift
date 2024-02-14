import IMGLYEditor
import SwiftUI

extension SceneSelection.Scene {
  init(_ resource: String, title: LocalizedStringKey, colorPalette: [NamedColor]? = nil) {
    self.title = title
    url = Bundle.main.url(forResource: resource, withExtension: "scene")!
    image = Bundle.main.url(forResource: resource, withExtension: "png")!
    self.colorPalette = colorPalette
  }
}

struct SceneSelection<Editor: View>: View {
  typealias Scenes = [(title: String, colorPalette: [(name: LocalizedStringKey, color: CGColor)]?)]

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

  private let editor: (URL) -> Editor
  @ViewBuilder private let scenes: [Scene]

  init(
    scenes: Scenes,
    @ViewBuilder editor: @escaping (_ sceneURL: URL) -> Editor
  ) {
    self.scenes = scenes.map {
      let resource = $0.title.replacingOccurrences(of: " ", with: "_").lowercased()
      return .init(resource, title: LocalizedStringKey($0.title),
                   colorPalette: $0.colorPalette?.map { .init($0.name, $0.color) })
    }
    self.editor = editor
  }

  var body: some View {
    let shadowColor = Color(red: 0.09, green: 0.09, blue: 0.09)
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 16)], spacing: 16) {
        ForEach(scenes) { scene in
          ShowcaseLink {
            editor(scene.url)
              .imgly.colorPalette(scene.colorPalette)
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
