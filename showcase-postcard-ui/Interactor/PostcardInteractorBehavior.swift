import IMGLYEditorUI
import IMGLYEngine
import SwiftUI

final class PostcardInteractorBehavior: InteractorBehavior {
  func loadScene(_ context: InteractorContext, from url: URL, with insets: EdgeInsets?) async throws {
    try await DefaultInteractorBehavior.default.loadScene(context, from: url, with: insets)
    context.interactor.selectionColors = try context.engine.selectionColors(
      forPage: 0,
      includeDisabled: true,
      setDisabled: true
    )
    try context.engine.editor.setGlobalScope(key: ScopeKey.editorAdd.rawValue, value: .defer)
  }

  func rootBottomBarItems(_ context: InteractorContext) throws -> [RootBottomBarItem] {
    if context.interactor.page != 1 {
      return [.fab, .selectionColors]
    } else {
      guard let id = context.engine.block.find(byName: "Greeting").first else {
        return []
      }
      return [
        .font(id, fontFamilies: [
          "Caveat", "AmaticSC", "Courier Prime", "Archivo", "Roboto", "Parisienne"
        ]),
        .fontSize(id),
        .color(id, colorPalette: [
          .init("Governor Bay", .hex("#263BAA")!),
          .init("Resolution Blue", .hex("#002094")!),
          .init("Stratos", .hex("#001346")!),
          .init("Blue Charcoal", .hex("#000514")!),
          .init("Black", .hex("#000000")!),
          .init("Dove Gray", .hex("#696969")!),
          .init("Dusty Gray", .hex("#999999")!)
        ])
      ]
    }
  }

  func updateState(_: InteractorContext) throws {}
}

extension InteractorBehavior where Self == PostcardInteractorBehavior {
  static var postcardUI: Self { Self() }
}

extension Interactor {
  static var postcardUI: Interactor { Interactor(behavior: .postcardUI) }
}
