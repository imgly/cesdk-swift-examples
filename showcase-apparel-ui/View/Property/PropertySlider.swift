import SwiftUI

struct PropertySlider<T: MappedType & BinaryFloatingPoint>: View where T.Stride: BinaryFloatingPoint {
  let title: LocalizedStringKey
  let bounds: ClosedRange<T>
  let property: String

  @EnvironmentObject private var interactor: Interactor

  init(_ title: LocalizedStringKey, in bounds: ClosedRange<T>, property: String) {
    self.title = title
    self.bounds = bounds
    self.property = property
  }

  var body: some View {
    Slider(value: interactor.bind(property: property, default: bounds.lowerBound, completion: nil),
           in: bounds) { started in
      if !started {
        interactor.addUndoStep()
      }
    }
    .accessibilityLabel(title)
  }
}
