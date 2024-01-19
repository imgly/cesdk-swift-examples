import SwiftUI

struct EffectPropertyOptions: View {
  let title: LocalizedStringKey
  let properties: [EffectProperty]
  let backTitle: LocalizedStringKey

  @Binding var sheetState: EffectSheetState
  @EnvironmentObject private var interactor: Interactor

  var body: some View {
    List {
      ForEach(properties, id: \.property) { property in
        Section(property.label) {
          PropertySlider(
            property.label,
            in: property.range,
            property: property.property,
            selection: property.id,
            defaultValue: property.defaultValue
          )
        }
      }
    }
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          Task {
            sheetState = .selection
            var detents: Set<PresentationDetent> = [.tiny]
            if properties.count > 1 {
              detents.insert(.medium)
            }
            interactor.sheet.commit { model in
              model = .init(model.mode, model.type)
              model.detents = [.tiny]
              model.detent = .tiny
            }
          }
        } label: {
          NavigationLabel(backTitle, direction: .backward)
        }
      }
    }
  }
}
