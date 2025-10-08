import SwiftUI
@_spi(Internal) import IMGLYCoreUI

struct ModalPhotoPicker<Editor: View>: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  private let editor: (URL) -> Editor

  struct PhotoResultWrapper: Identifiable {
    let id = UUID()
    let url: URL
  }

  @ViewBuilder private var label: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
      if let subtitle {
        Text(subtitle).font(.footnote)
      }
    }
  }

  @State private var isPhotoPickerPresented = false
  @State private var photoResult: PhotoResultWrapper?
  @State private var alert: AlertState?

  init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey? = nil,
    @ViewBuilder editor: @escaping (URL) -> Editor
  ) {
    self.title = title
    self.subtitle = subtitle
    self.editor = editor
  }

  var body: some View {
    Button {
      isPhotoPickerPresented = true
    } label: {
      label
    }
    .imgly.photoRoll(isPresented: $isPhotoPickerPresented, media: [.image], maxSelectionCount: 1) { result in
      do {
        let assets = try result.get()
        guard let (url, _) = assets.first else { return }
        photoResult = PhotoResultWrapper(url: url)
      } catch {
        alert = .importFailure(error: error)
      }
    }
    .fullScreenCover(item: $photoResult) { result in
      NavigationView {
        editor(result.url)
      }
    }
    .imgly.alert($alert)
  }
}

private extension AlertState {
  static func importFailure(error: Error) -> Self {
    AlertState(
      title: "Import Failed",
      message: error.localizedDescription,
      buttons: [.init(title: "OK", action: {})],
    )
  }
}
