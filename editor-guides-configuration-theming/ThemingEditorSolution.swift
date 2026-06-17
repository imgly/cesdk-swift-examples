import IMGLYEditor
import SwiftUI

/// Editor demonstrating how to theme the editor's appearance.
///
/// This example shows how to:
/// - Let the editor follow the system color scheme (default)
/// - Force the editor into light or dark mode
/// - Switch the color scheme at runtime through a Picker
struct ThemingEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  enum Demo: String, CaseIterable, Identifiable {
    case followSystem = "Follow System"
    case forceDark = "Force Dark"
    case runtimeToggle = "Runtime Toggle"
    var id: Self { self }
  }

  enum ThemeOption: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    var id: Self { self }

    var colorScheme: ColorScheme? {
      switch self {
      case .system: nil
      case .light: .light
      case .dark: .dark
      }
    }
  }

  @State private var selectedDemo: Demo = .followSystem
  @State private var selectedTheme: ThemeOption = .system
  @State private var isPresented = false

  // highlight-theming-system
  var editorFollowingSystem: some View {
    Editor(settings)
      .imgly.configuration { GuideEditorConfiguration() }
  }

  // highlight-theming-system

  // highlight-theming-override
  var editorForcedDark: some View {
    Editor(settings)
      .imgly.configuration { GuideEditorConfiguration() }
      .preferredColorScheme(.dark)
  }

  // highlight-theming-override

  // highlight-theming-toggle
  var editorWithRuntimeToggle: some View {
    Editor(settings)
      .imgly.configuration { GuideEditorConfiguration() }
      .preferredColorScheme(selectedTheme.colorScheme)
  }

  // highlight-theming-toggle

  @ViewBuilder
  var editor: some View {
    switch selectedDemo {
    case .followSystem:
      editorFollowingSystem
    case .forceDark:
      editorForcedDark
    case .runtimeToggle:
      editorWithRuntimeToggle
    }
  }

  var body: some View {
    VStack(spacing: 16) {
      Picker("Demo", selection: $selectedDemo) {
        ForEach(Demo.allCases) { demo in
          Text(demo.rawValue).tag(demo)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)

      if selectedDemo == .runtimeToggle {
        Picker("Theme", selection: $selectedTheme) {
          ForEach(ThemeOption.allCases) { option in
            Text(option.rawValue).tag(option)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
      }

      Button("Use the Editor") {
        isPresented = true
      }
      .padding()
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalEditor {
        editor
      }
    }
  }
}

#Preview {
  ThemingEditorSolution()
}
