import SwiftUI

struct Canvas: View {
  @EnvironmentObject private var interactor: Interactor

  let zoomPadding: CGFloat

  static let safeCoordinateSpaceName = "safeCanvas"
  static let safeCoordinateSpace = CoordinateSpace.named(safeCoordinateSpaceName)

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  private let viewDebugging = false

  private var safeAreaInsetHeight: CGFloat {
    let safeAreaInsetHeight: CGFloat = verticalSizeClass == .compact ? 33 : 60
    let paddingBottom: CGFloat = 8
    return safeAreaInsetHeight + paddingBottom
  }

  var body: some View {
    ZStack {
      ZStack {
        if viewDebugging {
          Color.red.opacity(0.2).border(.red).padding(5)
        }
        interactor.canvas
          .canvasAction(anchor: .top) {
            CanvasMenu()
          }
      }
      .ignoresSafeArea()
      GeometryReader { safeCanvas in
        Group {
          if viewDebugging {
            Color.blue.opacity(0.2).border(.blue).allowsHitTesting(false)
          } else {
            Color.clear
          }
        }
        .coordinateSpace(name: Self.safeCoordinateSpaceName)
        .preference(key: CanvasGeometryKey.self, value: Geometry(safeCanvas, .local))
      }
    }
    .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: zoomPadding) }
    .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: zoomPadding) }
    .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: zoomPadding) }
    .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: zoomPadding) }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      if interactor.isEditing, interactor.editMode != .text {
        ZStack {
          if viewDebugging {
            Color.green.opacity(0.2).border(.green).ignoresSafeArea()
          } else {
            Color.clear
          }
        }
        .frame(height: safeAreaInsetHeight)
        .transition(.move(edge: .bottom))
      }
    }
    .overlay(alignment: .bottom) {
      if interactor.isEditing {
        BottomToolbar()
          .ignoresSafeArea(.keyboard)
          .allowsHitTesting(!interactor.sheet.isPresented)
          .transition(.move(edge: .bottom))
      }
    }
  }
}

struct Canvas_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
