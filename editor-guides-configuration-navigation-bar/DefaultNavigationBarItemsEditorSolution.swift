import IMGLYApparelEditor
import IMGLYDesignEditor
import IMGLYPhotoEditor
import IMGLYPostcardEditor
import IMGLYVideoEditor
import SwiftUI

struct DefaultNavigationBarItemsEditorSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var designEditor: some View {
    DesignEditor(settings)
      // highlight-designEditor-navigationBarItems
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePagesMode()
          NavigationBar.Buttons.export()
        }
      }
    // highlight-designEditor-navigationBarItems
  }

  var photoEditor: some View {
    PhotoEditor(settings)
      // highlight-photoEditor-navigationBarItems
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePreviewMode()
          NavigationBar.Buttons.export()
        }
      }
    // highlight-photoEditor-navigationBarItems
  }

  var videoEditor: some View {
    VideoEditor(settings)
      // highlight-videoEditor-navigationBarItems
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.export()
        }
      }
    // highlight-videoEditor-navigationBarItems
  }

  var apparelEditor: some View {
    ApparelEditor(settings)
      // highlight-apparelEditor-navigationBarItems
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePreviewMode()
          NavigationBar.Buttons.export()
        }
      }
    // highlight-apparelEditor-navigationBarItems
  }

  var postcardEditor: some View {
    PostcardEditor(settings)
      // highlight-postcardEditor-navigationBarItems
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor()
          NavigationBar.Buttons.previousPage(
            label: { _ in NavigationLabel("Design", direction: .backward) },
          )
        }
        NavigationBar.ItemGroup(placement: .principal) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePreviewMode()
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.nextPage(
            label: { _ in NavigationLabel("Write", direction: .forward) },
          )
          NavigationBar.Buttons.export()
        }
      }
    // highlight-postcardEditor-navigationBarItems
  }

  private enum Solution: String, Identifiable, CaseIterable {
    case design, photo, video, apparel, postcard
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
        case .apparel: apparelEditor
        case .postcard: postcardEditor
        }
      }
    }
  }
}

#Preview {
  DefaultNavigationBarItemsEditorSolution()
}
