import SwiftUI

struct ColorPropertyButton: View {
  let name: LocalizedStringKey
  let color: CGColor
  let isEnabled: Bool
  @Binding var selection: CGColor

  private var isSelected: Bool {
    if isEnabled,
       let selection = try? selection.rgba(),
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
        Label(name, systemImage: "circle.fill")
          .foregroundStyle(Color(cgColor: color))
        Image(systemName: "circle")
          .opacity(isSelected ? 1 : 0)
          .scaleEffect(1.4)
      }
      .font(.title)
    }
    .accessibilityLabel(name)
  }
}

struct ColorPropertyButton_Previews: PreviewProvider {
  @State static var color: CGColor = .blue

  static var previews: some View {
    HStack {
      ColorPropertyButton(name: "Blue", color: .blue, isEnabled: true, selection: $color)
      ColorPropertyButton(name: "Blue", color: .blue, isEnabled: false, selection: $color)
      ColorPropertyButton(name: "Yellow", color: .yellow, isEnabled: true, selection: $color)
    }
    .labelStyle(.iconOnly)
  }
}
