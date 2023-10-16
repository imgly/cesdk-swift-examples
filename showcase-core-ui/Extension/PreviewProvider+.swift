import SwiftUI
import SwiftUIBackports

extension PreviewProvider {
  @ViewBuilder static
  func previewState<Value>(_ value: Value,
                           content: @escaping (_ binding: Binding<Value>) -> some View) -> some View {
    StatefulPreviewContainer(value) { binding in
      content(binding)
    }
  }

  @ViewBuilder static var assetLibraryPreview: some View {
    previewState(true) { binding in
      Button("Show Asset Library") {
        binding.wrappedValue = true
      }
      .sheet(isPresented: binding) {
        PreviewAssetLibrary()
      }
    }
  }

  @ViewBuilder static var defaultAssetLibraryPreviews: some View {
    assetLibraryPreview
    assetLibraryPreview.nonDefaultPreviewSettings()
  }
}

private struct PreviewAssetLibrary: View {
  @State var hidePresentationDragIndicator: Bool = false

  var body: some View {
    AssetLibrary(sceneMode: .video)
      .assetLibraryInteractor(AssetLibraryInteractorMock())
      .assetLibraryDismissButton(
        Button {} label: {
          Label("Dismiss", systemImage: "chevron.down.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.secondary)
            .font(.title2)
        }
      )
      .onPreferenceChange(PresentationDragIndicatorHiddenKey.self) { newValue in
        hidePresentationDragIndicator = newValue
      }
      .conditionalPresentationDragIndicator(hidePresentationDragIndicator ? .hidden : .automatic)
      .presentationDetentsForPreview()
  }
}

private extension View {
  @ViewBuilder func presentationDetentsForPreview() -> some View {
    if #available(iOS 16.0, *) {
      presentationDetents([.medium, .large], selection: .constant(.large))
    } else {
      backport.presentationDetents([.medium, .large], selection: .constant(.large))
    }
  }
}

private struct StatefulPreviewContainer<Value, Content: View>: View {
  @State var value: Value
  let content: (Binding<Value>) -> Content

  var body: some View {
    content($value)
  }

  init(_ value: Value, content: @escaping (_ binding: Binding<Value>) -> Content) {
    _value = .init(wrappedValue: value)
    self.content = content
  }
}
