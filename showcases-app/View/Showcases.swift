import IMGLYApparelEditor
import IMGLYDesignEditor
import IMGLYPhotoEditor
import IMGLYPostcardEditor
import IMGLYVideoEditor
import SwiftUI

struct Showcases: View {
  @State var mode = ShowcaseMode.navigationLink

  @ViewBuilder var showcases: some View {
    Section(title: "Photo Editor",
            subtitle: "Edit photo.") {
      Showcase(
        view: PhotoEditor(settings),
        title: "Default Photo Editor",
        subtitle: "Loads empty image.",
      )
      Showcase(
        view: CustomPhotoEditor().showcaseMode(mode),
        title: "Custom Photo Editor",
        subtitle: "Custom format and photo selection.",
      ).showcaseMode(.navigationLink)
      ModalPhotoPicker(
        title: "Background Removal Photo Editor",
        subtitle: "AI-powered background removal using Apple Vision framework.",
      ) { url in
        BackgroundRemovalEditorSolution(url: url)
      }
    }
    Section(title: "Design Editor",
            subtitle: "Built to edit various designs.") {
      Showcase(
        view: DesignEditor(settings),
        title: "Default Design Editor",
        subtitle: "Loads empty design scene.",
      )
      Showcase(
        view: CustomDesignEditor(),
        title: "Custom Design Editor",
        subtitle: "Loads custom design scene and adds Unsplash asset source and library.",
      )
    }
    Section(title: "Video Editor",
            subtitle: "Edit video.") {
      Showcase(
        view: VideoEditor(settings),
        title: "Default Video Editor",
        subtitle: "Loads empty video scene.",
      )
      Showcase(
        view: CustomVideoEditor(),
        title: "Custom Video Editor",
        subtitle: "Custom video scene and adds Unsplash asset source and library.",
      )
      ModalCameraShowcase(
        title: "React to Video",
        // swiftlint:disable:next line_length
        subtitle: "Loads a video into the camera that plays along while recording, then shows the result in the editor.",
        mode: .reaction(
          .vertical,
          video: URL(
            // swiftlint:disable:next line_length
            string: "https://cdn.img.ly/assets/demo/v3/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
          )!,
        ),
      )
      ModalCameraShowcase(
        title: "Dual Camera to Video Editor",
        subtitle: "Shows the dual camera, then imports all the recorded clips into the editor.",
        mode: .dualCamera(),
      )
    }
    Section(title: "Apparel Editor",
            subtitle: "Customize and export a print-ready design with a mobile apparel editor.") {
      Showcase(
        view: ApparelEditor(settings),
        title: "Default Apparel Editor",
        subtitle: "Loads empty apparel scene.",
      )
      Showcase(
        view: CustomApparelEditor(),
        title: "Custom Apparel Editor",
        subtitle: "Loads custom apparel scene and adds Unsplash asset source and library.",
      )
    }
    Section(title: "Post- & Greeting-Card Editor",
            subtitle: "Built to facilitate optimal card design, from changing accent colors to selecting fonts.") {
      Showcase(
        view: PostcardEditor(settings),
        title: "Default Postcard Editor",
        subtitle: "Loads empty postcard scene.",
      )
      Showcase(
        view: CustomPostcardEditor().showcaseMode(mode),
        title: "Custom Postcard Editor",
        subtitle: "Custom postcard scene selection and adds Unsplash asset source and library.",
      ).showcaseMode(.navigationLink)
    }
    Section(title: "Documentation Editor Examples") {
      Group {
        Showcase(view: EditorSwiftUI(), title: "Quickstart: SwiftUI")
        Showcase(view: EditorUIKitWrapper(), title: "Quickstart: UIKit")
      }
      Group {
        Showcase(view: DesignEditorSolution(), title: "Solutions: Design Editor")
        Showcase(view: VideoEditorSolution(), title: "Solutions: Video Editor")
        Showcase(view: PhotoEditorSolution(), title: "Solutions: Photo Editor")
        Showcase(view: ApparelEditorSolution(), title: "Solutions: Apparel Editor")
        Showcase(view: PostcardEditorSolution(), title: "Solutions: Postcard Editor")
      }
      Group {
        Showcase(view: BasicEditorSolution(), title: "Configuration: Basics")
        Showcase(view: CallbacksEditorSolution(), title: "Configuration: Callbacks")
        Showcase(view: ForceCropSolution(), title: "Configuration: Force Crop")
        Showcase(view: ThemingEditorSolution(), title: "Configuration: Theming")
        Showcase(view: ColorPaletteEditorSolution(), title: "Configuration: Color Palette")
        Showcase(view: DefaultAssetLibraryEditorSolution(), title: "Configuration: Default Asset Library")
        Showcase(view: CustomAssetLibraryEditorSolution(), title: "Configuration: Custom Asset Library")
        Showcase(view: NavigationBarEditorSolution(), title: "Configuration: Navigation Bar")
        Showcase(view: DefaultNavigationBarItemsEditorSolution(), title: "Configuration: Default Navigation Bar Items")
        Showcase(view: NavigationBarItemEditorSolution(), title: "Configuration: Navigation Bar Item")
        Showcase(view: DockEditorSolution(), title: "Configuration: Dock")
        Showcase(view: DefaultDockItemsEditorSolution(), title: "Configuration: Default Dock Items")
        Showcase(view: CustomPanelSolution(), title: "Configuration: Custom Panel")
        Showcase(view: DockItemEditorSolution(), title: "Configuration: Dock Item")
        Showcase(view: InspectorBarEditorSolution(), title: "Configuration: Inspector Bar")
        Showcase(view: InspectorBarItemEditorSolution(), title: "Configuration: Inspector Bar Item")
        Showcase(view: CanvasMenuEditorSolution(), title: "Configuration: Canvas Menu")
        Showcase(view: CanvasMenuItemEditorSolution(), title: "Configuration: Canvas Menu Item")
        Showcase(view: AddButtonEditorSolution(), title: "UI Extensions: Add a New Button")
        Showcase(view: HideElementsEditorSolution(), title: "Customization: Hide Elements")
        Showcase(view: RearrangeButtonsEditorSolution(), title: "Customization: Rearrange Buttons")
      }
    }.showcaseMode(.navigationLink)
    Section(title: "Documentation Camera Examples") {
      Group {
        Showcase(view: CameraSwiftUI(), title: "Quickstart: SwiftUI")
        Showcase(view: CameraUIKitWrapper(), title: "Quickstart: UIKit")
      }
      Group {
        Showcase(view: RecordingsCameraSolution(), title: "Recordings")
      }
      Group {
        Showcase(view: ConfiguredCameraSolution(), title: "Configuration")
      }
    }.showcaseMode(.navigationLink)
  }

  var body: some View {
    SwiftUI.Section("Settings") {
      Picker("Presentation Mode", selection: $mode) {
        ForEach(ShowcaseMode.allCases) {
          Text(LocalizedStringKey(String(describing: $0)))
        }
      }
    }
    showcases
      .showcaseMode(mode)
  }
}

private struct EditorUIKitWrapper: UIViewControllerRepresentable {
  func makeUIViewController(context _: Context) -> EditorUIKit {
    EditorUIKit()
  }

  func updateUIViewController(_: EditorUIKit, context _: Context) {}
}

private struct CameraUIKitWrapper: UIViewControllerRepresentable {
  func makeUIViewController(context _: Context) -> CameraUIKit {
    CameraUIKit()
  }

  func updateUIViewController(_: CameraUIKit, context _: Context) {}
}
