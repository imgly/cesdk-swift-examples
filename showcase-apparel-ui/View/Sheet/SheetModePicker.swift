import SwiftUI

struct SheetModePicker: View {
  @EnvironmentObject private var interactor: Interactor

  @Binding var sheet: SheetModel
  let modes: [SheetMode]

  var allowedModes: [SheetMode] {
    modes.filter { mode in
      interactor.isAllowed(mode)
    }
  }

  var body: some View {
    Picker(sheet.type.localizedStringKey(suffix: " Options"), selection: $sheet.mode) {
      ForEach(allowedModes) { mode in
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
