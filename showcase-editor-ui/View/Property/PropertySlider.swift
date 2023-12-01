import SwiftUI

struct PropertySlider<T: MappedType & BinaryFloatingPoint>: View where T.Stride: BinaryFloatingPoint {
  let title: LocalizedStringKey
  let bounds: ClosedRange<T>
  let property: Property
  let mapping: Mapping
  let setter: Interactor.PropertySetter<T>
  let propertyBlock: PropertyBlock?

  typealias Mapping = (_ value: Binding<T>, _ bounds: ClosedRange<T>) -> Binding<T>

  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  init(_ title: LocalizedStringKey, in bounds: ClosedRange<T>, property: Property,
       mapping: @escaping Mapping = { value, _ in value },
       setter: @escaping Interactor.PropertySetter<T> = Interactor.Setter.set(),
       propertyBlock: PropertyBlock? = nil) {
    self.title = title
    self.bounds = bounds
    self.property = property
    self.mapping = mapping
    self.setter = setter
    self.propertyBlock = propertyBlock
  }

  var binding: Binding<T> {
    interactor.bind(id, propertyBlock, property: property, default: bounds.lowerBound, setter: setter, completion: nil)
  }

  var body: some View {
    Slider(value: mapping(binding, bounds),
           in: bounds) { started in
      if !started {
        interactor.addUndoStep()
      }
    }
    .accessibilityLabel(title)
  }
}
