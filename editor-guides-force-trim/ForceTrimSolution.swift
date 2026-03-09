import IMGLYVideoEditor
import SwiftUI

struct ForceTrimSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey, // pass nil for evaluation mode with watermark
    userID: "<your unique user id>",
  )

  var editor: some View {
    VideoEditor(settings)
      // highlight-forceTrim-onLoaded
      .imgly.onLoaded { context in
        // highlight-forceTrim-constraints
        context.setVideoDurationConstraints(
          minimumVideoDuration: 5,
          maximumVideoDuration: 15,
        )
        // highlight-forceTrim-constraints
      }
    // highlight-forceTrim-onLoaded
  }

  @State private var isPresented = false

  var body: some View {
    Button("Use the Editor") {
      isPresented = true
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
}

#Preview {
  ForceTrimSolution()
}
