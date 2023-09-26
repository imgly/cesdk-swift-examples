import IMGLYCore
import Media
import SwiftUI

public struct AudioUploadButton: View {
  public init() {}

  @State private var showFileImporter = false

  public var body: some View {
    Button {
      showFileImporter.toggle()
    } label: {
      UploadAddLabel()
    }
    .assetFileUploader(isPresented: $showFileImporter, allowedContentTypes: [.audio])
  }
}

struct AudioUploadButton_Previews: PreviewProvider {
  static var previews: some View {
    defaultAssetLibraryPreviews
  }
}
