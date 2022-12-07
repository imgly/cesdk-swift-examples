import SwiftUI

struct CanvasAction<Action>: ViewModifier where Action: View {
  @EnvironmentObject private var interactor: Interactor

  let anchor: UnitPoint
  @ViewBuilder let action: Action

  @GestureState private var isDragging = false
  @GestureState private var isMagnifying = false
  @GestureState private var isRotating = false

  private var showAction: Bool {
    interactor.isCanvasActionEnabled && !isDragging && !isMagnifying && !isRotating
  }

  @Environment(\.layoutDirection) private var layoutDirection

  private func anchor(for rect: CGRect, _ size: CGSize) -> CGPoint {
    let anchorX = layoutDirection == .leftToRight ? anchor.x : 1 - anchor.x
    let x = rect.minX + (anchorX * rect.width)
    let y = rect.minY + (anchor.y * rect.height)
    return CGPoint(x: layoutDirection == .leftToRight ? x : size.width - x, y: y)
  }

  func body(content: Content) -> some View {
    ZStack {
      GeometryReader { geometry in
        content
        #if os(iOS)
        .simultaneousGesture(
          DragGesture().updating($isDragging) { _, state, _ in state = true }
        )
        .simultaneousGesture(
          MagnificationGesture().updating($isMagnifying) { _, state, _ in state = true }
        )
        .simultaneousGesture(
          RotationGesture().updating($isRotating) { _, state, _ in state = true }
        )
        #endif

        if let selection = interactor.selection {
          action
            .position(anchor(for: selection.boundingBox, geometry.size))
            .allowsHitTesting(showAction)
            .disabled(!showAction)
            .opacity(showAction ? 1 : 0)
            .clipped()
        }
      }
    }
  }
}

struct CanvasAction_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
