import SwiftUI

struct StrokeOptions: View {
  @EnvironmentObject private var interactor: Interactor

  @Binding var isEnabled: Bool

  var body: some View {
    if interactor.hasStroke {
      StrokeColorOptions()
      if isEnabled {
        PropertySlider<Float>("Width", in: 0 ... 20, property: "stroke/width")
        PropertyPicker<StrokeStyle>("Style", property: "stroke/style")
        PropertyPicker<StrokePosition>("Position", property: "stroke/position")
          .disabled(interactor.sheet.type == .text)
        PropertyPicker<StrokeJoin>("Join", property: "stroke/cornerGeometry")
      }
    }
  }
}

struct StrokeOptions_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.style, .shape))
  }
}
