import SwiftUI

public extension View {
  @available(iOS 15.0, *)
  func colorPicker(
    _ title: LocalizedStringKey? = nil,
    isPresented: Binding<Bool>,
    selection: Binding<CGColor>,
    supportsOpacity: Bool = true,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) -> some View {
    background(ColorPickerSheet(title: title, isPresented: isPresented, selection: selection,
                                supportsOpacity: supportsOpacity, onEditingChanged: onEditingChanged))
  }
}

@available(iOS 15.0, *)
private struct ColorPickerSheet: UIViewRepresentable {
  var title: LocalizedStringKey?
  @Binding var isPresented: Bool
  @Binding var selection: CGColor
  var supportsOpacity: Bool
  var onEditingChanged: (Bool) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(selection: $selection, isPresented: $isPresented, onEditingChanged: onEditingChanged)
  }

  class Coordinator: NSObject, UIColorPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    @Binding var selection: CGColor
    @Binding var isPresented: Bool
    var didPresent = false
    var onEditingChanged: (Bool) -> Void
    var lastContinuously = false

    init(selection: Binding<CGColor>, isPresented: Binding<Bool>, onEditingChanged: @escaping (Bool) -> Void) {
      _selection = selection
      _isPresented = isPresented
      self.onEditingChanged = onEditingChanged
    }

    func colorPickerViewController(_: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
      selection = color.cgColor
      if !continuously || continuously != lastContinuously {
        onEditingChanged(continuously)
      }
      lastContinuously = continuously
    }

    func colorPickerViewControllerDidFinish(_: UIColorPickerViewController) {
      isPresented = false
      didPresent = false
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
      isPresented = false
      didPresent = false
    }
  }

  @MainActor func getTopViewController(from view: UIView) -> UIViewController? {
    guard var top = view.window?.rootViewController else {
      return nil
    }
    while let next = top.presentedViewController {
      top = next
    }
    return top
  }

  func makeUIView(context _: Context) -> UIView {
    let view = UIView()
    view.isHidden = true
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    if isPresented, !context.coordinator.didPresent {
      let modal = UIColorPickerViewController()
      modal.selectedColor = UIColor(cgColor: selection)
      modal.supportsAlpha = supportsOpacity
      modal.title = title?.stringValue
      modal.delegate = context.coordinator
      modal.modalPresentationStyle = .popover
      modal.popoverPresentationController?.sourceView = uiView
      modal.popoverPresentationController?.sourceRect = uiView.bounds
      modal.presentationController?.delegate = context.coordinator
      let top = getTopViewController(from: uiView)
      top?.present(modal, animated: true)
      context.coordinator.didPresent = true
    }
  }
}

private extension LocalizedStringKey {
  var stringKey: String? {
    Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
  }

  var stringValue: String? {
    guard let stringKey else { return nil }
    let localizedString = NSLocalizedString(stringKey, bundle: Bundle.main, value: stringKey, comment: "")
    if localizedString != stringKey {
      return localizedString
    }
    return NSLocalizedString(stringKey, bundle: Bundle.bundle, value: stringKey, comment: "")
  }
}
