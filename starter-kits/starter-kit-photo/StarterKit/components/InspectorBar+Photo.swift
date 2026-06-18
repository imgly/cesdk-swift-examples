import IMGLYEditor
import IMGLYEngine

// MARK: - Inspector Bar

extension PhotoEditorConfiguration {
  /// The default inspector bar configuration.
  static var defaultInspectorBar: InspectorBar.Configuration {
    InspectorBar.Configuration { builder in
      // highlight-starter-kit-inspector-bar
      builder.items { _ in
        InspectorBar.Buttons.replace()

        InspectorBar.Buttons.editText()
        InspectorBar.Buttons.formatText()
        InspectorBar.Buttons.textOnPath()
        InspectorBar.Buttons.fillStroke()
        InspectorBar.Buttons.textBackground()
        InspectorBar.Buttons.textStylePresets()
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
      builder.enabled = {
        try $0.engine.block.getType($0.selection.block) != DesignBlockType.page.rawValue
      }
      // highlight-starter-kit-inspector-bar
    }
  }
}
