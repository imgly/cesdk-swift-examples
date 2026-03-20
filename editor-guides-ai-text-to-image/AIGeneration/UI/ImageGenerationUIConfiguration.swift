import Foundation
import SwiftUI

// MARK: - Sheet Configuration

/// Configuration for the image generation sheet (navigation, buttons, feature toggles)
public struct ImageGenerationUIConfiguration: Sendable {
  public let navigationTitle: String
  public let showsCancelButton: Bool
  public let generateButtonTitle: String
  public let enablesImageToImage: Bool
  public let showsTransparencyOption: Bool
  public let showsVectorOption: Bool
  public let showsFormatSelector: Bool

  public init(
    navigationTitle: String = String(localized: "ai_generation_title", table: aiGenerationTable),
    showsCancelButton: Bool = true,
    generateButtonTitle: String = String(localized: "ai_generation_generate_button", table: aiGenerationTable),
    enablesImageToImage: Bool = true,
    showsTransparencyOption: Bool = false,
    showsVectorOption: Bool = false,
    showsFormatSelector: Bool = true
  ) {
    self.navigationTitle = navigationTitle
    self.showsCancelButton = showsCancelButton
    self.generateButtonTitle = generateButtonTitle
    self.enablesImageToImage = enablesImageToImage
    self.showsTransparencyOption = showsTransparencyOption
    self.showsVectorOption = showsVectorOption
    self.showsFormatSelector = showsFormatSelector
  }
}

public extension ImageGenerationUIConfiguration {
  @MainActor
  init(
    for aiService: any AIImageService,
    navigationTitle: String = String(localized: "ai_generation_title", table: aiGenerationTable),
    showsCancelButton: Bool = true,
    generateButtonTitle: String = String(localized: "ai_generation_generate_button", table: aiGenerationTable),
    enablesImageToImage: Bool = false,
    showsFormatSelector: Bool = true
  ) {
    self.init(
      navigationTitle: navigationTitle,
      showsCancelButton: showsCancelButton,
      generateButtonTitle: generateButtonTitle,
      enablesImageToImage: enablesImageToImage,
      showsTransparencyOption: aiService.supportsTransparentBackground,
      showsVectorOption: aiService.supportsVectorOutput,
      showsFormatSelector: showsFormatSelector,
    )
  }

  @MainActor
  static func adaptive(for aiService: any AIImageService) -> ImageGenerationUIConfiguration {
    ImageGenerationUIConfiguration(for: aiService)
  }
}

// MARK: - Form Configuration

/// Configuration for the text generation form (sections, styles, layout)
public struct TextGenerationConfiguration: Sendable {
  // Section visibility
  public let showsPromptInput: Bool
  public let showsOutputTypeSelector: Bool
  public let showsStyleSelector: Bool
  public let showsFormatSelector: Bool
  public let showsBackgroundSelector: Bool
  public let showsTransparencyInfo: Bool
  public let enablesImageToImage: Bool

  // Section titles
  public let promptSectionTitle: String
  public let styleSectionTitle: String
  public let formatSectionTitle: String
  public let backgroundSectionTitle: String

  // Prompt configuration
  public let promptMinHeight: CGFloat
  public let promptBackgroundColor: Color
  public let promptCornerRadius: CGFloat
  public let maxPromptLength: Int?

  // Available options
  public let availableImageStyles: [ImageStyle]
  public let availableVectorStyles: [VectorStyle]
  public let availableFormats: [FormatOption]
  public let availableBackgrounds: [BackgroundOption]

  // Layout
  public let sectionSpacing: CGFloat

  // Messages
  public let transparencyInfoMessage: String

  public init(
    showsPromptInput: Bool = true,
    showsOutputTypeSelector: Bool = true,
    showsStyleSelector: Bool = true,
    showsFormatSelector: Bool = true,
    showsBackgroundSelector: Bool = false,
    showsTransparencyInfo: Bool = true,
    enablesImageToImage: Bool = true,
    promptSectionTitle: String = String(localized: "ai_generation_section_prompt", table: aiGenerationTable),
    styleSectionTitle: String = String(localized: "ai_generation_section_style", table: aiGenerationTable),
    formatSectionTitle: String = String(localized: "ai_generation_section_format", table: aiGenerationTable),
    backgroundSectionTitle: String = String(localized: "ai_generation_background", table: aiGenerationTable),
    promptMinHeight: CGFloat = 100,
    promptBackgroundColor: Color = Color(.systemBackground),
    promptCornerRadius: CGFloat = 10,
    maxPromptLength: Int? = nil,
    availableImageStyles: [ImageStyle] = ImageStyle.allCases,
    availableVectorStyles: [VectorStyle] = VectorStyle.allCases,
    availableFormats: [FormatOption] = FormatOption.allCases,
    availableBackgrounds: [BackgroundOption] = BackgroundOption.allCases,
    sectionSpacing: CGFloat = 20,
    transparencyInfoMessage: String = String(
      localized: "ai_generation_transparency_message",
      table: aiGenerationTable,
    )
  ) {
    self.showsPromptInput = showsPromptInput
    self.showsOutputTypeSelector = showsOutputTypeSelector
    self.showsStyleSelector = showsStyleSelector
    self.showsFormatSelector = showsFormatSelector
    self.showsBackgroundSelector = showsBackgroundSelector
    self.showsTransparencyInfo = showsTransparencyInfo
    self.enablesImageToImage = enablesImageToImage
    self.promptSectionTitle = promptSectionTitle
    self.styleSectionTitle = styleSectionTitle
    self.formatSectionTitle = formatSectionTitle
    self.backgroundSectionTitle = backgroundSectionTitle
    self.promptMinHeight = promptMinHeight
    self.promptBackgroundColor = promptBackgroundColor
    self.promptCornerRadius = promptCornerRadius
    self.maxPromptLength = maxPromptLength
    self.availableImageStyles = availableImageStyles
    self.availableVectorStyles = availableVectorStyles
    self.availableFormats = availableFormats
    self.availableBackgrounds = availableBackgrounds
    self.sectionSpacing = sectionSpacing
    self.transparencyInfoMessage = transparencyInfoMessage
  }

  public static let `default` = TextGenerationConfiguration()

  public static let simple = TextGenerationConfiguration(
    showsOutputTypeSelector: false,
    showsStyleSelector: false,
    showsBackgroundSelector: false,
    enablesImageToImage: false,
    availableFormats: [.squareHD],
  )

  public static let advanced = TextGenerationConfiguration(
    maxPromptLength: 4000,
    sectionSpacing: 24,
  )
}
