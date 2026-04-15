import IMGLYEditor
import SwiftUI

struct CustomDesignEditor: View {
  var body: some View {
    let url = Bundle.main.url(forResource: "template_01_ig_post_1_1", withExtension: "scene")!
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await DesignEditorConfiguration.defaultOnCreate(createScene: { engine in
              try await OnCreate.loadScene(from: url)(engine)
              try engine.asset.addSource(UnsplashAssetSource(host: secrets.unsplashHost))
            })(engine)
          }
        }
        CustomEditorConfiguration()
      }
  }
}
