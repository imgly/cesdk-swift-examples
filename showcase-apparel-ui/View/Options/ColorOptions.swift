import SwiftUI

struct ColorOptions: View {
  @Binding var isEnabled: Bool
  @Binding var color: CGColor

  struct NamedColor: Identifiable {
    var id: CGColor { color }
    let name: LocalizedStringKey
    let color: CGColor
  }

  private let colors: [NamedColor] = [
    ("Blue", CGColor.blue),
    ("Green", CGColor.green),
    ("Yellow", CGColor.yellow),
    ("Red", CGColor.red),
    ("Black", CGColor.black),
    ("White", CGColor.white)
  ].map {
    NamedColor(name: $0.0, color: $0.1)
  }

  var body: some View {
    HStack {
      NoColorButton(isEnabled: $isEnabled)
      Spacer()
      ForEach(colors) {
        ColorPropertyButton(name: $0.name, color: $0.color, isEnabled: isEnabled, selection: $color)
        Spacer()
      }
      ColorPicker("Color Picker", selection: $color)
        .labelsHidden()
    }
  }
}

struct ColorOptions_Previews: PreviewProvider {
  @State static var color: CGColor = .blue

  static var previews: some View {
    VStack {
      ColorOptions(isEnabled: .constant(true), color: $color)
      ColorOptions(isEnabled: .constant(false), color: $color)
    }
    .labelStyle(.iconOnly)
  }
}
