import SwiftUI

struct FillColorImage: View {
  let isEnabled: Bool
  @Binding var color: CGColor

  var body: some View {
    ZStack {
      Image(systemName: "circle")
        .foregroundColor(.secondary)
        .scaleEffect(1.05)
      Image(systemName: "circle.fill")
        .foregroundStyle(.image(Image("transparent_color_pattern", bundle: Bundle.bundle)))
      if isEnabled {
        Image(systemName: "circle.fill")
          .foregroundStyle(Color(cgColor: color))
      } else {
        Image(systemName: "circle.slash")
          .foregroundStyle(.black, .clear)
      }
    }
  }
}

struct StrokeColorImage: View {
  let isEnabled: Bool
  @Binding var color: CGColor

  var body: some View {
    ZStack {
      Image(systemName: "circle")
        .foregroundColor(.secondary)
        .scaleEffect(1.05)
      Image("custom.circle.circle.fill", bundle: Bundle.bundle)
        .foregroundColor(.secondary)
        .scaleEffect(0.9)
      Image("custom.circle.circle.fill", bundle: Bundle.bundle)
        .foregroundStyle(.image(Image("transparent_color_pattern", bundle: Bundle.bundle)))
      if isEnabled {
        Image("custom.circle.circle.fill", bundle: Bundle.bundle)
          .foregroundStyle(Color(cgColor: color))
      } else {
        Image(systemName: "circle.slash")
          .foregroundStyle(.black, .clear)
      }
    }
  }
}

struct ColorImage_Previews: PreviewProvider {
  static func constant(_ color: Color) -> Binding<CGColor> {
    .constant(color.asCGColor)
  }

  @ViewBuilder static var colors: some View {
    VStack {
      HStack {
        FillColorImage(isEnabled: true, color: constant(.red))
        FillColorImage(isEnabled: true, color: constant(.red.opacity(0.5)))
        FillColorImage(isEnabled: false, color: constant(.red))
        FillColorImage(isEnabled: false, color: constant(.red.opacity(0.5)))
      }
      HStack {
        StrokeColorImage(isEnabled: true, color: constant(.red))
        StrokeColorImage(isEnabled: true, color: constant(.red.opacity(0.5)))
        StrokeColorImage(isEnabled: false, color: constant(.red))
        StrokeColorImage(isEnabled: false, color: constant(.red.opacity(0.5)))
      }
      ZStack {
        AdaptiveOverlay {
          FillColorImage(isEnabled: true, color: constant(.red))
        } overlay: {
          StrokeColorImage(isEnabled: false, color: constant(.red.opacity(0.5)))
        }
      }
    }
    .font(.title)
  }

  static var previews: some View {
    colors
    colors.nonDefaultPreviewSettings()
  }
}