import AVFoundation
@_spi(Internal) import IMGLYCoreUI
import SwiftUI

@MainActor
struct ContentView: View {
  private let title = "CE.SDK Showcases"
  @State private var isCameraSheetShown = false

  // MARK: - Appetize Deep Linking

  /// The showcase the docs asked for, or `nil` so an unknown ID lands on the
  /// showcase list instead of an empty screen. Resolved once, so a body update
  /// does not rebuild the pushed showcase.
  private let appetizeGuideDestination: AnyView?
  @State private var isShowingAppetizeGuide = false

  init(appetizeGuideID: String? = nil) {
    appetizeGuideDestination = appetizeGuideID.flatMap(AppetizeGuides.destination(for:))
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
        if let destination = appetizeGuideDestination {
          NavigationLink(isActive: $isShowingAppetizeGuide) {
            destination
          } label: {
            EmptyView()
          }
        }
      }
    }
    // `StackNavigationViewStyle` forces to deinitialize the view and thus its engine when exiting a showcase.
    .navigationViewStyle(.stack)
    .modifier(CameraShowcase(isCameraSheetShown: $isCameraSheetShown))
    .accessibilityIdentifier("showcases")
    .onAppear {
      try? AVAudioSession.sharedInstance().setCategory(.playback)
      if appetizeGuideDestination != nil {
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
