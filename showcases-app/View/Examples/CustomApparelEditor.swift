import IMGLYApparelEditor
import SwiftUI

struct CustomApparelEditor: View {
  var body: some View {
    let url = Bundle.main.url(forResource: "apparel-ui-b-1", withExtension: "scene")!
    ApparelEditor(settings)
      .customEditorConfiguration(scene: url)
  }
}
