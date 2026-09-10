import IMGLYEditor

// MARK: - Inspector Bar

extension DesignEditorConfiguration {
  /// The default inspector bar configuration.
  static var defaultInspectorBar: InspectorBar.Configuration {
    InspectorBar.Configuration { builder in
      // highlight-starter-kit-inspector-bar
      builder.items { _ in
        InspectorBar.Buttons.replace()

        InspectorBar.Buttons.editText()
        InspectorBar.Buttons.formatText()
        InspectorBar.Buttons.fillStroke()
        InspectorBar.Buttons.textBackground()
        InspectorBar.Buttons.crop()

        InspectorBar.Buttons.adjustments()
        InspectorBar.Buttons.filter()
        InspectorBar.Buttons.effect()
        InspectorBar.Buttons.blur()
        InspectorBar.Buttons.shape()

        InspectorBar.Buttons.selectGroup()
        InspectorBar.Buttons.enterGroup()

        InspectorBar.Buttons.layer()
        InspectorBar.Buttons.duplicate()
        InspectorBar.Buttons.delete()
      }
      // highlight-starter-kit-inspector-bar
    }
  }
}
