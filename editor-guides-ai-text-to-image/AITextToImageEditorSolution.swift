import IMGLYEditor
import IMGLYEngine
import SwiftUI

/// String table name for AI generation localization.
/// The `AIGeneration.xcstrings` catalog is bundled with this showcase.
public let aiGenerationTable = "AIGeneration"

/// Design Editor with AI-powered text-to-image generation capabilities.
///
/// This view demonstrates how to:
/// - Initialize the IMG.LY Design Editor
/// - Add custom AI generation buttons to the editor dock
/// - Present AI image generation sheets using IMG.LY's native sheet system
/// - Integrate fal.ai for text-to-image and image-to-image generation
/// - Insert generated images into the editor canvas
@MainActor
struct AITextToImageEditorSolution: View {
  let settings = EngineSettings(
    license: secrets.licenseKey,
    userID: "<your unique user id>",
  )

  // MARK: - Properties

  private let aiService: any AIImageService

  // MARK: - Initialization

  init() {
    aiService = FalAIService(model: .recraftV3, proxyURL: secrets.falAIProxyURL)
  }

  // MARK: - Body

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        DesignEditorConfiguration { builder in
          builder.dock { dock in
            dock.modify { context, items in
              items.addFirst {
                aiGeneratorButton(context: context)
              }
            }
          }
          builder.inspectorBar { inspectorBar in
            inspectorBar.modify { context, items in
              items.addFirst {
                imageInspectorButton(context: context)
              }
            }
          }
        }
      }
  }

  // MARK: - Dock Button

  private func aiGeneratorButton(context: Dock.Context) -> some Dock.Item {
    Dock.Button(
      id: "ly.img.aiGenerator",
      action: { context in
        presentAIGeneratorSheet(context: context)
      },
      label: { _ in
        Label(
          String(localized: "ai_generation_dock_button", table: aiGenerationTable),
          systemImage: "sparkles.rectangle.stack",
        )
      },
    )
  }

  private func presentAIGeneratorSheet(context: Dock.Context) {
    let delegate = DockImageGenerationDelegate(dockContext: context, aiService: aiService)
    context.eventHandler.send(.openSheet(
      style: .default(isFloating: true, detent: .height(450), detents: [.height(450)]),
      content: {
        ImageGenerationSheet(
          delegate: delegate,
          aiService: aiService,
          enablesImageToImage: true,
        )
      },
    ))
  }

  // MARK: - Inspector Bar Button

  private func imageInspectorButton(context: InspectorBar.Context) -> some InspectorBar.Item {
    InspectorBar.Button(
      id: "ly.img.inspectorBar.aiEdit",
      action: { context in
        presentImageEnhancementSheet(context: context)
      },
      label: { _ in
        Label(
          String(localized: "ai_generation_inspector_button", table: aiGenerationTable),
          systemImage: "wand.and.stars",
        )
      },
      isEnabled: { _ in true },
      isVisible: { context in context.selection.fillType == .image },
    )
  }

  private func presentImageEnhancementSheet(context: InspectorBar.Context) {
    let delegate = InspectorImageGenerationDelegate(inspectorContext: context, aiService: aiService)
    context.eventHandler.send(.openSheet(
      style: .default(isFloating: true, detent: .height(450), detents: [.height(450)]),
      content: {
        ImageGenerationSheet(
          delegate: delegate,
          aiService: aiService,
          enablesImageToImage: false,
          showsFormatSelector: false,
        )
      },
    ))
  }
}
