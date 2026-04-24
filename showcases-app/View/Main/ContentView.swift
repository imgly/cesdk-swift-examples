import AVFoundation
@_spi(Internal) import IMGLYCoreUI
import enum IMGLYEngine.LicenseError
import SwiftUI

@MainActor
struct ContentView: View {
  private let title = "CE.SDK Showcases"
  @State private var isCameraSheetShown = false

  // MARK: - Appetize Deep Linking

  var appetizeGuideID: String?
  @State private var isShowingAppetizeGuide = false

  @ViewBuilder
  private func appetizeGuideDestination(for guideID: String) -> some View {
    switch guideID {
    case "forceCrop": ForceCropSolution()
    default: EmptyView()
    }
  }

  var body: some View {
    NavigationView {
      List {
        Showcases()
      }
      .listStyle(.sidebar)
      .navigationTitle(title)
      .toolbar {
        Button {
          isCameraSheetShown.toggle()
        } label: {
          Label("Camera", systemImage: "camera")
        }
        .buttonStyle(.borderedProminent)
      }
      .imgly.buildInfo(ciBuildsHost: secrets.ciBuildsHost, githubRepo: secrets.githubRepo)
      .background {
        if let guideID = appetizeGuideID {
          NavigationLink(isActive: $isShowingAppetizeGuide) {
            appetizeGuideDestination(for: guideID)
          } label: {
            EmptyView()
          }
        }
      }
    }
    // `StackNavigationViewStyle` forces to deinitialize the view and thus its engine when exiting a showcase.
    .navigationViewStyle(.stack)
    .alert("License Key Required", isPresented: .constant(secrets.licenseKey.isEmpty)) {} message: {
      let message = LicenseError.missing.errorDescription ?? ""
      Text(verbatim: "Please enter a `licenseKey` in `Secrets.swift`!\n\(message)")
    }
    .modifier(CameraShowcase(isCameraSheetShown: $isCameraSheetShown))
    .accessibilityIdentifier("showcases")
    .onAppear {
      try? AVAudioSession.sharedInstance().setCategory(.playback)
      if appetizeGuideID != nil {
        isShowingAppetizeGuide = true
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    ContentView()
      .imgly.nonDefaultPreviewSettings()
  }
}
