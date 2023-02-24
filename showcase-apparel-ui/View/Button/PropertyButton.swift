import SwiftUI

struct PropertyButton<T: Labelable>: View {
  let property: T
  @Binding var selection: T?

  private var isSelected: Bool { selection == property }
  private var isDisabled: Bool { selection == nil }

  var body: some View {
    Button {
      selection = isSelected ? nil : property
    } label: {
      property.label
    }
    .foregroundColor(isSelected || isDisabled ? .accentColor : .primary)
    .disabled(isDisabled)
  }
}

struct TextPropertyButton_Previews: PreviewProvider {
  @State static var property: HorizontalAlignment? = .center

  static var previews: some View {
    HStack {
      ForEach(HorizontalAlignment.allCases) {
        PropertyButton(property: $0, selection: $property)
      }
    }
    .labelStyle(.iconOnly)
  }
}
