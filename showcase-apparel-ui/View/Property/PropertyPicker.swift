import SwiftUI

struct PropertyPicker<T: MappedEnum>: View {
  let title: LocalizedStringKey
  let property: String

  @EnvironmentObject private var interactor: Interactor

  init(_ title: LocalizedStringKey, property: String) {
    self.title = title
    self.property = property
  }

  var body: some View {
    let values: [T] = interactor.enumValues(property: property)
    let selection: Binding<T?> = interactor.bind(property: property)

    MenuPicker(title: title, data: values, selection: selection)
  }
}
