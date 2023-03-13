import SwiftUI

struct StrokeOptions: View {
  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  @Binding var isEnabled: Bool

  var body: some View {
    if interactor.hasStroke(id) {
      StrokeColorOptions()
      if isEnabled {
        PropertySlider<Float>("Width", in: 0 ... 20, property: .key(.strokeWidth))
        PropertyPicker<StrokeStyle>("Style", property: .key(.strokeStyle))
        PropertyPicker<StrokePosition>("Position", property: .key(.strokePosition))
          .disabled(interactor.sheet.type == .text)
        PropertyPicker<StrokeJoin>("Join", property: .key(.strokeCornerGeometry))
      }
    }
  }
}

struct StrokeOptions_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.fillAndStroke, .shape))
  }
}
