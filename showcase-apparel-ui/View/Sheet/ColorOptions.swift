import SwiftUI

struct ColorOptions: View {
  @Binding var selection: CGColor

  @ViewBuilder func colorButton(_ name: LocalizedStringKey, _ color: CGColor,
                                selection: Binding<CGColor>) -> some View {
    ColorPropertyButton(name: name, color: color, selection: selection)
    Spacer()
  }

  var body: some View {
    HStack {
      colorButton("Blue", .blue, selection: $selection)
      colorButton("Green", .green, selection: $selection)
      colorButton("Yellow", .yellow, selection: $selection)
      colorButton("Red", .red, selection: $selection)
      colorButton("Black", .black, selection: $selection)
      colorButton("White", .white, selection: $selection)
      ColorPicker("Color Picker", selection: $selection)
        .labelsHidden()
    }
  }
}

struct ColorOptions_Previews: PreviewProvider {
  @State static var color = CGColor.blue

  static var previews: some View {
    ColorOptions(selection: $color)
      .labelStyle(.iconOnly)
  }
}
