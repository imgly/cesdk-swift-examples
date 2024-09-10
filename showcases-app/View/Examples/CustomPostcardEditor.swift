import IMGLYPostcardEditor
import SwiftUI

struct CustomPostcardEditor: View {
  private let scenes: SceneSelection.Scenes = [
    ("Thank you", colorPalette: [
      ("Petite Orchid", .imgly.hex("#E09F96")!),
      ("White", .imgly.hex("#FFFFFF")!),
      ("Claret", .imgly.hex("#761E40")!),
      ("Kimberly", .imgly.hex("#7471A3")!),
      ("Gondola", .imgly.hex("#20121F")!),
      ("Dove Gray", .imgly.hex("#696969")!),
      ("Dusty Gray", .imgly.hex("#999999")!)
    ]),
    ("Merry Christmas", colorPalette: [
      ("Fern Frond", .imgly.hex("#536F1A")!),
      ("White", .imgly.hex("#FFFFFF")!),
      ("Metallic Copper", .imgly.hex("#6B2923")!),
      ("Fuel Yellow", .imgly.hex("#F3AE2B")!),
      ("Black Bean", .imgly.hex("#051111")!),
      ("Dove Gray", .imgly.hex("#696969")!),
      ("Dusty Gray", .imgly.hex("#999999")!)
    ]),
    ("Bonjour Paris", colorPalette: [
      ("Black", .imgly.hex("#000000")!),
      ("White", .imgly.hex("#FFFFFF")!),
      ("Purple Heart", .imgly.hex("#4932D1")!),
      ("Persimmon", .imgly.hex("#FE6755")!),
      ("Scorpion", .imgly.hex("#606060")!),
      ("Dove Gray", .imgly.hex("#696969")!),
      ("Dusty Gray", .imgly.hex("#999999")!)
    ]),
    ("Wish you were here", colorPalette: [
      ("Mandy", .imgly.hex("#E75050")!),
      ("White", .imgly.hex("#FFFFFF")!),
      ("Cod Gray", .imgly.hex("#111111")!),
      ("Shark", .imgly.hex("#282929")!),
      ("Patina", .imgly.hex("#619888")!),
      ("Dove Gray", .imgly.hex("#696969")!),
      ("Dusty Gray", .imgly.hex("#999999")!)
    ])
  ]

  var body: some View {
    SceneSelection(scenes: scenes) { url in
      PostcardEditor(settings)
        .customEditorConfiguration(scene: url)
    }
  }
}
