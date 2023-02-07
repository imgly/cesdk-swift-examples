import SwiftUI

struct PropertyNavigationLink<T: MappedEnum>: View {
  let title: LocalizedStringKey
  let property: String

  @EnvironmentObject private var interactor: Interactor

  init(_ title: LocalizedStringKey, property: String) {
    self.title = title
    self.property = property
  }

  var body: some View {
    let values: [T] = interactor.enumValues(property: property)
    let binding: Binding<T?> = interactor.bind(property: property)
    let selection: Binding<T.ID?> = .init {
      binding.wrappedValue?.id
    } set: { id in
      let value = values.first { id == $0.id }
      if let value {
        binding.wrappedValue = value
      }
    }

    NavigationLinkPicker(title: title, data: values, selection: selection) { value, isSelected in
      Label(value.localizedStringKey, systemImage: "checkmark")
        .labelStyle(.icon(hidden: !isSelected))
    } linkLabel: { selection in
      if let selection {
        Text(selection.localizedStringKey)
      }
    }
  }
}
