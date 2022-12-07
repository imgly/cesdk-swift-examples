import SwiftUI

struct ColorPropertyButton: View {
  let name: LocalizedStringKey
  let color: CGColor
  @Binding var selection: CGColor

  private var isSelected: Bool {
    if let selection = try? selection.rgba(),
       let color = try? color.rgba() {
      return selection == color
    }
    return false
  }

  var body: some View {
    Button {
      selection = color
    } label: {
      ZStack {
        Image(systemName: "circle")
          .foregroundColor(.secondary)
          .scaleEffect(1.05)
        Label(name, systemImage: isSelected ? "circle.inset.filled" : "circle.fill")
          .foregroundStyle(Color(cgColor: color))
      }
      .font(.title)
    }
    .accessibilityLabel(name)
  }
}

struct ColorPropertyButton_Previews: PreviewProvider {
  @State static var color = CGColor.blue

  static var previews: some View {
    HStack {
      ColorPropertyButton(name: "Blue", color: .blue, selection: $color)
      ColorPropertyButton(name: "Yellow", color: .yellow, selection: $color)
    }
    .labelStyle(.iconOnly)
  }
}
