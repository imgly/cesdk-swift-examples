import SwiftUI

struct SheetModePicker: View {
  @Binding var sheet: SheetModel
  let modes: [SheetMode]

  var body: some View {
    Picker(sheet.type.localizedStringKey(suffix: " Options"), selection: $sheet.mode) {
      ForEach(modes) { mode in
        mode.taggedLabel
      }
    }
    .frame(maxWidth: min(100 * CGFloat(modes.count), 266))
    .pickerStyle(.segmented)
    .labelStyle(.adaptiveTitleOnly)
  }
}

struct SheetModePicker_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.edit, .text))
  }
}
