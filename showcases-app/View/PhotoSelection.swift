import SwiftUI

extension Format {
  init(_ resource: String, title: LocalizedStringKey, size: CGSize?) {
    self.title = title
    image = Bundle.main.url(forResource: resource, withExtension: "png")!
    imageDark = Bundle.main.url(forResource: resource.appending("_dark"), withExtension: "png")
    self.size = size
  }
}

private struct Format: Identifiable {
  var id: URL { image }
  /// Scene title.
  let title: LocalizedStringKey
  /// Image size.
  let size: CGSize?
  /// Preview image.
  let image: URL
  /// Dark preview image.
  let imageDark: URL?
}

struct PhotoSelection<Editor: View>: View {
  // swiftlint:disable:next large_tuple
  typealias Formats = [(resource: String, title: LocalizedStringKey, size: CGSize?)]

  private let editor: (URL, CGSize?) -> Editor
  @ViewBuilder private let formats: [Format]

  init(
    formats: Formats,
    @ViewBuilder editor: @escaping (_ imageURL: URL, _ size: CGSize?) -> Editor
  ) {
    self.formats = formats.map {
      .init($0.resource, title: $0.title, size: $0.size)
    }
    self.editor = editor
  }

  var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 144, maximum: 144), spacing: 16)], spacing: 16) {
        ForEach(formats) { format in
          ShowcaseLink {
            editor(Bundle.main.url(forResource: "sample_image", withExtension: "jpg")!,
                   format.size)
          } label: {
            Thumbnail(format: format)
          }
        }
      }
      .padding(16)
    }
    .background {
      Color(uiColor: .secondarySystemBackground)
        .ignoresSafeArea()
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Choose Format")
  }
}

private struct Thumbnail: View {
  @Environment(\.colorScheme) private var colorScheme

  let format: Format

  private var gradientColors: [Color] {
    var colors: [Color] = [.init(uiColor: .quaternarySystemFill),
                           .init(uiColor: .systemFill)]
    if colorScheme == .dark {
      colors.reverse()
    }
    return colors
  }

  private var imageURL: URL {
    if colorScheme == .dark, let imageDark = format.imageDark {
      imageDark
    } else {
      format.image
    }
  }

  var body: some View {
    VStack {
      AsyncImage(url: imageURL) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
      } placeholder: {
        ProgressView()
      }
      .frame(width: 88, height: 80)

      Text(format.title)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)
        .lineLimit(2, reservesSpace: format.size == nil)

      if let size = format.size {
        Text(String("\(Int(size.width)) × \(Int(size.height)) px"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
      }
    }
    .frame(width: 144, height: 144)
    .background {
      RoundedRectangle(cornerRadius: 13)
        .fill(.linearGradient(.init(colors: gradientColors),
                              startPoint: .top, endPoint: .bottom))
    }
  }
}
