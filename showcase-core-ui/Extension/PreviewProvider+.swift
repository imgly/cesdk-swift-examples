import SwiftUI

extension PreviewProvider {
  @ViewBuilder static
  func previewState<Value>(_ value: Value,
                           content: @escaping (_ binding: Binding<Value>) -> some View) -> some View {
    StatefulPreviewContainer(value) { binding in
      content(binding)
    }
  }
}

private struct StatefulPreviewContainer<Value, Content: View>: View {
  @State var value: Value
  let content: (Binding<Value>) -> Content

  var body: some View {
    content($value)
  }

  init(_ value: Value, content: @escaping (_ binding: Binding<Value>) -> Content) {
    _value = .init(wrappedValue: value)
    self.content = content
  }
}
