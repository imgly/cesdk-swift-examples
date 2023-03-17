import SwiftUI

public struct ExportButton: View {
  @EnvironmentObject private var interactor: Interactor

  public init() {}

  public var body: some View {
    ActionButton(.export)
      .disabled(interactor.isLoading || interactor.isExporting)
      .activitySheet($interactor.export)
  }
}

struct ExportButton_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
