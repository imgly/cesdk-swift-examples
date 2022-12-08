import SwiftUI

struct FontButton: View {
  let fontFamily: FontFamily
  @Binding var selectedFontFamilyID: String?

  private var isSelected: Bool { fontFamily.id == selectedFontFamilyID }

  var body: some View {
    Button {
      selectedFontFamilyID = fontFamily.id
    } label: {
      Label(fontFamily.name, systemImage: "checkmark")
    }
    .labelStyle(.icon(hidden: !isSelected, titleFont: .custom(fontFamily.someFontName ?? "", size: 17)))
    .foregroundColor(isSelected ? .accentColor : .primary)
  }
}

struct FontButton_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.style, .text))
  }
}
