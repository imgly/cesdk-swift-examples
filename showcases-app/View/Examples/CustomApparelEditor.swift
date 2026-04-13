import IMGLYEditor
import SwiftUI

struct CustomApparelEditor: View {
  var body: some View {
    let url = Bundle.main.url(forResource: "apparel-ui-b-1", withExtension: "scene")!
    Editor(settings)
      .imgly.configuration {
        ApparelEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await ApparelEditorConfiguration.defaultOnCreate(createScene: { engine in
              try await OnCreate.loadScene(from: url)(engine)
              try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
            })(engine)
          }
        }
        CustomEditorConfiguration()
      }
  }
}
