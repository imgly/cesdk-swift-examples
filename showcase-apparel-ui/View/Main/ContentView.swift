import SwiftUI

public struct ContentView: View {
  @StateObject private var interactor = Interactor()

  @Environment(\.layoutDirection) private var layoutDirection

  private var url = Bundle.bundle.url(forResource: "apparel-ui", withExtension: "scene")!

  /// Initialize with `url` to load a custom scene.
  public init(scene url: URL? = nil) {
    if let url {
      self.url = url
    }
  }

  /// Initialize with `sheet` for previews.
  init(sheet: SheetState? = nil) {
    _interactor = .init(wrappedValue: Interactor(sheet: sheet))
  }

  @State private var canvasGeometry: Geometry?
  @State private var sheetGeometry: Geometry?
  private var sheetGeometryIfPresented: Geometry? { interactor.sheet.isPresented ? sheetGeometry : nil }
  private let zoomPadding: CGFloat = 16

  private func zoomParameters(canvasGeometry: Geometry?,
                              sheetGeometry: Geometry?) -> (insets: EdgeInsets?, canvasHeight: CGFloat) {
    let canvasHeight = canvasGeometry?.size.height ?? 0

    let insets: EdgeInsets?
    if let sheetGeometry, let canvasGeometry {
      var sheetInsets = canvasGeometry.safeAreaInsets
      let height = canvasGeometry.size.height
      let sheetMinY = sheetGeometry.frame.minY - sheetGeometry.safeAreaInsets.top
      sheetInsets.bottom = max(sheetInsets.bottom, zoomPadding + height - sheetMinY)
      sheetInsets.bottom = min(sheetInsets.bottom, height * 0.7)
      insets = sheetInsets
    } else {
      insets = canvasGeometry?.safeAreaInsets
    }

    if var rtl = insets, layoutDirection == .rightToLeft {
      swap(&rtl.leading, &rtl.trailing)
      return (rtl, canvasHeight)
    }

    return (insets, canvasHeight)
  }

  @State private var interactivePopGestureRecognizer: UIGestureRecognizer?

  public var body: some View {
    Canvas(zoomPadding: zoomPadding)
      .allowsHitTesting(interactor.isEditing)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(!interactor.isEditing)
      .introspectNavigationController { navigationController in
        // Disable swipe-back gesture and restore `onDisappear`
        interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer
        interactivePopGestureRecognizer?.isEnabled = false
      }
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar {
        ToolbarItemGroup(placement: .principal) {
          PrincipalToolbar()
            .labelStyle(.adaptiveIconOnly)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          ExportButton()
            .labelStyle(.adaptiveIconOnly)
        }
      }
      .onPreferenceChange(CanvasGeometryKey.self) { newValue in
        canvasGeometry = newValue
      }
      .onChange(of: canvasGeometry) { newValue in
        let zoom = zoomParameters(canvasGeometry: newValue, sheetGeometry: sheetGeometryIfPresented)
        interactor.updateZoom(with: zoom.insets, canvasHeight: zoom.canvasHeight)
      }
      .onChange(of: interactor.editMode) { newValue in
        if newValue == .text, !interactor.sheet.isPresented {
          Interactor.resignFirstResponder()
          interactor.sheet = .init(.edit, .text)
        }
        let zoom = zoomParameters(canvasGeometry: canvasGeometry, sheetGeometry: sheetGeometryIfPresented)
        interactor.updateZoom(with: zoom.insets, canvasHeight: zoom.canvasHeight)
      }
      .onChange(of: interactor.textCursorPosition) { newValue in
        let zoom = zoomParameters(canvasGeometry: canvasGeometry, sheetGeometry: sheetGeometry)
        interactor.zoomToText(with: zoom.insets, canvasHeight: zoom.canvasHeight, cursorPosition: newValue)
      }
      .sheet(isPresented: $interactor.sheet.isPresented) {
        let zoom = zoomParameters(canvasGeometry: canvasGeometry, sheetGeometry: sheetGeometryIfPresented)
        interactor.updateZoom(with: zoom.insets, canvasHeight: zoom.canvasHeight)
      } content: {
        GeometryReader { proxy in
          Sheet()
            .preference(key: SheetGeometryKey.self,
                        value: Geometry(proxy, Canvas.safeCoordinateSpace))
            .errorAlert(isSheet: true)
        }
        .onPreferenceChange(SheetGeometryKey.self) { newValue in
          sheetGeometry = newValue
        }
        .onChange(of: sheetGeometry) { newValue in
          let zoom = zoomParameters(canvasGeometry: canvasGeometry, sheetGeometry: newValue)
          interactor.updateZoom(with: zoom.insets, canvasHeight: zoom.canvasHeight)
        }
      }
      .errorAlert(isSheet: false)
      .onAppear {
        interactor.onAppear()
        let zoom = zoomParameters(canvasGeometry: canvasGeometry, sheetGeometry: sheetGeometryIfPresented)
        interactor.loadScene(from: url, with: zoom.insets)
      }
      .onWillDisappear {
        interactor.onWillDisappear()
      }
      .onDisappear {
        interactor.onDisappear()
        interactivePopGestureRecognizer?.isEnabled = true
      }
      .environmentObject(interactor)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
  }
}
