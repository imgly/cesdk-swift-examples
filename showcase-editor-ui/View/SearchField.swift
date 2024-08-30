import SwiftUI

struct SearchField: View {
  @Binding var searchText: String
  var prompt: Text?

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  var body: some View {
    HStack(spacing: 0) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)
        .imageScale(.medium)
        .padding([.trailing], 4)
      TextField("Search", text: $searchText,
                prompt: prompt?.foregroundColor(.secondary))
        .submitLabel(.search)
      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.secondary)
            .imageScale(.medium)
            .padding([.leading], 9)
        }
        .buttonStyle(.borderless)
      }
    }
    .padding([.leading, .trailing], 6)
    .padding([.bottom, .top], verticalSizeClass == .compact ? 2 : 7)
    .background {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(uiColor: .tertiarySystemFill))
    }
  }
}
