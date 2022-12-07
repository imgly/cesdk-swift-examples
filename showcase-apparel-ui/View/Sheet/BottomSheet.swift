import SwiftUI

struct BottomSheet<Principal: View, Content: View>: View {
  let title: Text
  @ViewBuilder let principal: Principal
  @ViewBuilder let content: Content

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      GeometryReader { proxy in
        ZStack {
          content
        }
        .preference(key: SheetContentGeometryKey.self,
                    value: Geometry(proxy, Canvas.safeCoordinateSpace))
      }
      .ignoresSafeArea(.keyboard)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(title)
      .toolbar {
        ToolbarItemGroup(placement: .principal) {
          principal
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .symbolRenderingMode(.hierarchical)
              .foregroundColor(.secondary)
              .font(.title2)
          }
        }
      }
    }
  }
}

struct BottomSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
