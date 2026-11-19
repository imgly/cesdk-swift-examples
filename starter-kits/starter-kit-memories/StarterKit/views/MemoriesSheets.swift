import SwiftUI

/// The style picker. Choosing a style applies it at once, as one undo step.
struct MemoriesStylesSheet: View {
  @ObservedObject var model: MemoriesModel

  var body: some View {
    // A non-floating editor sheet needs a `NavigationView` or a `List` as its content.
    NavigationView {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(MemoriesStyles.all) { style in
            Button { Task { await model.applyStyle(id: style.id) } } label: {
              tile(style, isSelected: style.id == model.activeStyleID)
            }
            .buttonStyle(.plain)
            .disabled(model.isApplying)
          }
        }
        .padding()
      }
      .navigationTitle("Styles")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func tile(_ style: MemoriesStyle, isSelected: Bool) -> some View {
    VStack(spacing: 8) {
      style.previewBackground
        .overlay {
          if let url = model.styleThumbnails[style.id] {
            AsyncImage(url: url) { image in
              image.resizable().scaledToFill()
            } placeholder: {
              Color.clear
            }
          } else {
            Image(systemName: "photo")
              .font(.title)
              .foregroundStyle(.secondary)
          }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(4)
        .overlay {
          if isSelected {
            RoundedRectangle(cornerRadius: 16).strokeBorder(Color.accentColor, lineWidth: 3)
          }
        }
      Text(style.displayName)
        .font(.subheadline.weight(isSelected ? .semibold : .regular))
        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
    }
  }
}

/// The page volume, which scales the soundtrack and the video clips together.
struct MemoriesVolumeSheet: View {
  @ObservedObject var model: MemoriesModel

  var body: some View {
    NavigationView {
      VStack(spacing: 8) {
        HStack(spacing: 12) {
          Image(systemName: "speaker.fill")
          Slider(value: Binding(get: { model.volume }, set: { model.setVolume($0) }), in: 0 ... 1)
          Image(systemName: "speaker.wave.3.fill")
        }
        .foregroundStyle(.secondary)
        Text("\(Int(model.volume * 100))%")
          .font(.callout.monospacedDigit())
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 24)
      .navigationTitle("Volume")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
