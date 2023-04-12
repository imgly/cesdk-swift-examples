import SwiftUI

struct SheetState: BatchMutable {
  var isPresented: Bool
  var model: SheetModel
  var detent: PresentationDetent = .medium
  var detents: Set<PresentationDetent> = [.medium, .large]
  var largestUndimmedDetent: PresentationDetent? {
    if detents.contains(.medium) {
      return .medium
    } else if detents.contains(.small) {
      return .small
    } else {
      return nil
    }
  }

  /// Forwarded `model.mode`.
  var mode: SheetMode {
    get { model.mode }
    set { model.mode = newValue }
  }

  /// Forwarded `model.type`.
  var type: SheetType { model.type }

  /// Combined `model` and `isPresented`.
  var state: SheetModel? { isPresented ? model : nil }

  var isSearchable: Bool {
    switch mode {
    case .add, .replace:
      switch type {
      case .image, .shape, .sticker, .upload:
        return true
      default:
        return false
      }
    default:
      return false
    }
  }

  /// Hide sheet.
  init() {
    isPresented = false
    model = .init(.add, .image)
  }

  /// Show sheet with `mode` and `type`.
  init(_ mode: SheetMode, _ type: SheetType) {
    isPresented = true
    model = .init(mode, type)
  }
}
