@_spi(Internal) import IMGLYEditor
import IMGLYEngine
import SwiftUI

// MARK: - Dock Button IDs

extension Dock.Buttons.ID {
  /// The id of the ``Dock/Buttons/designColors(action:title:icon:isEnabled:isVisible:)`` button.
  static var designColors: EditorComponentID { "ly.img.component.dock.button.postcard.designColors" }
  /// The id of the ``Dock/Buttons/greetingColors(action:title:icon:isEnabled:isVisible:)`` button.
  static var greetingColors: EditorComponentID { "ly.img.component.dock.button.postcard.namedColors" }
  /// The id of the ``Dock/Buttons/greetingFont(action:title:icon:isEnabled:isVisible:)`` button.
  static var greetingFont: EditorComponentID { "ly.img.component.dock.button.postcard.greetingFont" }
  /// The id of the ``Dock/Buttons/greetingSize(action:title:icon:isEnabled:isVisible:)`` button.
  static var greetingSize: EditorComponentID { "ly.img.component.dock.button.postcard.greetingSize" }
}

// MARK: - Dock Buttons

extension Dock.Buttons {
  /// Creates a dock button that opens the selection colors sheet.
  static func designColors(
    action: @escaping Dock.Context.To<Void> = {
      $0.eventHandler.send(.openSheet(type: .designColors()))
    },
    @ViewBuilder title: @escaping Dock.Context.To<some View> = { _ in
      Text(.imgly.localized("ly_img_editor_dock_button_colors"))
    },
    @ViewBuilder icon: @escaping Dock.Context.To<some View> = { _ in SelectionColorsIcon() },
    isEnabled: @escaping Dock.Context.To<Bool> = { _ in true },
    isVisible: @escaping Dock.Context.To<Bool> = {
      try $0.engine.scene.getPages().first == $0.engine.scene.getCurrentPage()
    },
  ) -> some Dock.Item {
    Dock.Button(id: ID.designColors, action: action, label: { context in
      let title = try title(context)
      let icon = try icon(context)
      Label { title } icon: { icon }
    }, isEnabled: isEnabled, isVisible: isVisible)
  }

  /// Creates a dock button that opens the greeting color sheet.
  static func greetingColors(
    action: @escaping Dock.Context.To<Void> = {
      guard let id = $0.engine.block.find(byName: "Greeting").first else { return }
      $0.eventHandler.send(.openSheet(type: .greetingColors(id: id, colorPalette: [
        .init("Governor Bay", .imgly.hex("#263BAA")!),
        .init("Resolution Blue", .imgly.hex("#002094")!),
        .init("Stratos", .imgly.hex("#001346")!),
        .init("Blue Charcoal", .imgly.hex("#000514")!),
        .init("Black", .imgly.hex("#000000")!),
        .init("Dove Gray", .imgly.hex("#696969")!),
        .init("Dusty Gray", .imgly.hex("#999999")!),
      ])))
    },
    @ViewBuilder title: @escaping Dock.Context.To<some View> = { _ in
      Text(.imgly.localized("ly_img_editor_dock_button_colors"))
    },
    @ViewBuilder icon: @escaping Dock.Context.To<some View> = {
      let id = $0.engine.block.find(byName: "Greeting").first
      return FillColorIcon()
        .imgly.selection(id)
    },
    isEnabled: @escaping Dock.Context.To<Bool> = { _ in true },
    isVisible: @escaping Dock.Context.To<Bool> = {
      try $0.engine.scene.getPages().last == $0.engine.scene.getCurrentPage()
    },
  ) -> some Dock.Item {
    Dock.Button(id: ID.greetingColors, action: action, label: { context in
      let title = try title(context)
      let icon = try icon(context)
      Label { title } icon: { icon }
    }, isEnabled: isEnabled, isVisible: isVisible)
  }

  /// Creates a dock button that opens the greeting font sheet.
  static func greetingFont(
    action: @escaping Dock.Context.To<Void> = {
      guard let id = $0.engine.block.find(byName: "Greeting").first else { return }
      $0.eventHandler.send(.openSheet(type: .greetingFont(id: id, fontFamilies: [
        "Caveat", "Amatic SC", "Courier Prime", "Archivo", "Roboto", "Parisienne",
      ])))
    },
    @ViewBuilder title: @escaping Dock.Context.To<some View> = { _ in
      Text(.imgly.localized("ly_img_editor_dock_button_font"))
    },
    @ViewBuilder icon: @escaping Dock.Context.To<some View> = {
      let id = $0.engine.block.find(byName: "Greeting").first
      return FontIcon()
        .imgly.selection(id)
    },
    isEnabled: @escaping Dock.Context.To<Bool> = { _ in true },
    isVisible: @escaping Dock.Context.To<Bool> = {
      try $0.engine.scene.getPages().last == $0.engine.scene.getCurrentPage()
    },
  ) -> some Dock.Item {
    Dock.Button(id: ID.greetingFont, action: action, label: { context in
      let title = try title(context)
      let icon = try icon(context)
      Label { title } icon: { icon }
    }, isEnabled: isEnabled, isVisible: isVisible)
  }

  /// Creates a dock button that opens the greeting font size sheet.
  static func greetingSize(
    action: @escaping Dock.Context.To<Void> = {
      guard let id = $0.engine.block.find(byName: "Greeting").first else { return }
      $0.eventHandler.send(.openSheet(type: .greetingSize(id: id)))
    },
    @ViewBuilder title: @escaping Dock.Context.To<some View> = { _ in
      Text(.imgly.localized("ly_img_editor_dock_button_size"))
    },
    @ViewBuilder icon: @escaping Dock.Context.To<some View> = { context in
      let id = context.engine.block.find(byName: "Greeting").first
      return FontSizeIcon()
        .imgly.selection(id)
    },
    isEnabled: @escaping Dock.Context.To<Bool> = { _ in true },
    isVisible: @escaping Dock.Context.To<Bool> = {
      try $0.engine.scene.getPages().last == $0.engine.scene.getCurrentPage()
    },
  ) -> some Dock.Item {
    Dock.Button(id: ID.greetingSize, action: action, label: { context in
      let title = try title(context)
      let icon = try icon(context)
      Label { title } icon: { icon }
    }, isEnabled: isEnabled, isVisible: isVisible)
  }
}
