import IMGLYDesignEditor
import IMGLYPhotoEditor
import IMGLYVideoEditor
import SwiftUI

struct DefaultDockItemsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var designEditor: some View {
    DesignEditor(settings)
      // highlight-designEditor-dockItems
      .imgly.dockItems { _ in
        Dock.Buttons.elementsLibrary()
        Dock.Buttons.imglyPhotoRoll()
        Dock.Buttons.systemCamera()
        Dock.Buttons.imagesLibrary()
        Dock.Buttons.textLibrary()
        Dock.Buttons.shapesLibrary()
        Dock.Buttons.stickersLibrary()
        Dock.Buttons.resize()
      }
    // highlight-designEditor-dockItems
  }

  var photoEditor: some View {
    PhotoEditor(settings)
      // highlight-photoEditor-dockItems
      .imgly.dockItems { _ in
        Dock.Buttons.adjustments()
        Dock.Buttons.filter()
        Dock.Buttons.effect()
        Dock.Buttons.blur()
        Dock.Buttons.crop()
        Dock.Buttons.textLibrary()
        Dock.Buttons.shapesLibrary()
        Dock.Buttons.stickersLibrary()
      }
    // highlight-photoEditor-dockItems
  }

  var videoEditor: some View {
    VideoEditor(settings)
      // highlight-videoEditor-dockItems
      .imgly.dockItems { _ in
        Dock.Buttons.imglyPhotoRoll()
        Dock.Buttons.imglyCamera()
        Dock.Buttons.overlaysLibrary()
        Dock.Buttons.textLibrary()
        Dock.Buttons.stickersAndShapesLibrary()
        Dock.Buttons.audioLibrary()
        Dock.Buttons.voiceover()
        Dock.Buttons.reorder()
        Dock.Buttons.resize()
      }
    // highlight-videoEditor-dockItems
  }

  private enum Solution: String, Identifiable, CaseIterable {
    case design, photo, video
    var id: Self { self }
  }

  @State private var solution: Solution = .design

  @State private var isPresented = false

  var body: some View {
    Picker("Solution", selection: $solution) {
      ForEach(Solution.allCases) {
        Text($0.rawValue.capitalized + " Editor")
      }
    }
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        switch solution {
        case .design: designEditor
        case .photo: photoEditor
        case .video: videoEditor
        }
      }
    }
  }
}

#Preview {
  DefaultDockItemsEditorSolution()
}
