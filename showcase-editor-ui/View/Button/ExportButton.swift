import SwiftUI

public struct ExportButton: View {
  @EnvironmentObject private var interactor: Interactor

  public init() {}

  @ViewBuilder func button(_ action: Action) -> some View {
    Button {
      interactor.actionButtonTapped(for: action)
    } label: {
      action.label
    }
  }

  public var body: some View {
    button(.export)
      .disabled(interactor.isLoading || interactor.isExporting)
      .activitySheet($interactor.export)
  }
}

struct ExportButton_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
