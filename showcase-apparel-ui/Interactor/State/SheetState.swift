import IMGLYEngine
import SwiftUI

struct SheetState: BatchMutable {
  var isPresented: Bool
  var model: SheetModel
  var detent: PresentationDetent = .adaptiveMedium
  var detents: Set<PresentationDetent> = [.adaptiveMedium, .large]

  /// The inspected block.
  var selection: DesignBlockID?

  /// Forwarded `model.mode`.
  var mode: SheetMode {
    get { model.mode }
    set { model.mode = newValue }
  }

  /// Forwarded `model.type`.
  var type: SheetType { model.type }

  /// Combined `model` and `isPresented`.
  var state: SheetModel? { isPresented ? model : nil }

  /// Hide sheet.
  init() {
    isPresented = false
    model = .init(.add, .image)
  }

  /// Show sheet with `mode` and `type` for the inspected block `selection`.
  init(_ mode: SheetMode, _ type: SheetType, selection: DesignBlockID? = nil) {
    isPresented = true
    model = .init(mode, type)
    self.selection = selection
  }
}
