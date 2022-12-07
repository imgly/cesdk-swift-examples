import SwiftUI

struct TextPropertyButton: View {
  let property: TextProperty
  @Binding var selection: TextProperty?

  private var isSelected: Bool { selection == property }
  private var isDisabled: Bool { selection == .notAvailable }

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
  @State static var property: TextProperty? = .italic

  static var previews: some View {
    HStack {
      ForEach(TextProperty.allCases) {
        TextPropertyButton(property: $0, selection: $property)
      }
    }
    .labelStyle(.iconOnly)
  }
}
