import SwiftUI

/// Maps a documentation guide ID to the showcase its live demo opens.
///
/// The documentation embeds this app through Appetize and passes the ID as the
/// `guideID` launch argument. Every entry has a matching `appetizeGuideID` in
/// the guide's `ios.mdx`, so a new guide needs both sides to be added.
///
/// Camera guides have no entry — Appetize runs the app in a simulator, which
/// has no camera to preview.
@MainActor
enum AppetizeGuides {
  private static let destinations: [String: () -> AnyView] = {
    var destinations: [String: () -> AnyView] = [
      "addCaptions": { AnyView(AddCaptionsSolution()) },
      "addNewButton": { AnyView(AddButtonEditorSolution()) },
      "aiImageGeneration": { AnyView(AIImageGenerationSolution()) },
      "assetLibrary": { AnyView(AssetLibraryEditorSolution()) },
      "assetLibraryBasics": { AnyView(AssetLibraryBasicsSolution()) },
      "assetLibraryPanel": { AnyView(AssetLibraryPanelSolution()) },
      "autoCaptionsPlugin": { AnyView(AutoCaptionsPluginSolution()) },
      "backgroundRemovalPlugin": { AnyView(BackgroundRemovalPluginSolution()) },
      "canvasMenu": { AnyView(CanvasMenuEditorSolution()) },
      "colorPalette": { AnyView(ColorPaletteEditorSolution()) },
      "configurationBasics": { AnyView(BasicEditorSolution()) },
      "createCustomPanel": { AnyView(CreateCustomPanelSolution()) },
      "cropPresets": { AnyView(CropPresetsSolution()) },
      "customFeaturePlugin": { AnyView(CustomFeaturePluginSolution()) },
      "customFonts": { AnyView(CustomFontsSolution()) },
      "customLabels": { AnyView(CustomLabelsEditorSolution()) },
      "customizeBehaviour": { AnyView(CustomizeBehaviourSolution()) },
      "disableOrEnableFeatures": { AnyView(DisableOrEnableFeaturesEditorSolution()) },
      "dock": { AnyView(DockEditorSolution()) },
      "forceCrop": { AnyView(ForceCropSolution()) },
      "hideElements": { AnyView(HideElementsEditorSolution()) },
      "icons": { AnyView(IconsEditorSolution()) },
      "inspectorBar": { AnyView(InspectorBarEditorSolution()) },
      "navigationBar": { AnyView(NavigationBarEditorSolution()) },
      "notificationsAndDialogs": { AnyView(NotificationsAndDialogsSolution()) },
      "pageFormat": { AnyView(PageFormatSolution()) },
      "panel": { AnyView(CustomPanelSolution()) },
      "photoRoll": { AnyView(PhotoRollSolution()) },
      "quickActions": { AnyView(QuickActionsEditorSolution()) },
      "rearrangeButtons": { AnyView(RearrangeButtonsEditorSolution()) },
      "recordVoiceover": { AnyView(RecordVoiceoverSolution()) },
      "refreshAssets": { AnyView(RefreshAssetsSolution()) },
      "registerNewComponent": { AnyView(RegisterNewComponentSolution()) },
      "starterKitApparelEditor": { AnyView(ApparelEditorStarterKit()) },
      "starterKitDesignEditor": { AnyView(DesignEditorStarterKit()) },
      "starterKitPhotoEditor": { AnyView(PhotoEditorStarterKit()) },
      "starterKitPostcardEditor": { AnyView(PostcardEditorStarterKit()) },
      "starterKitVideoEditor": { AnyView(VideoEditorStarterKit()) },
      "theming": { AnyView(ThemingEditorSolution()) },
      "uiEvents": { AnyView(UiEventsEditorSolution()) },
      "userUpload": { AnyView(UserUploadSolution()) },
      "variableFonts": { AnyView(VariableFontsSolution()) },
    ]
    if #available(iOS 16.1, *) {
      destinations["changeUIFont"] = { AnyView(ChangeUIFontSolution()) }
    }
    return destinations
  }()

  /// The showcase for `guideID`, or `nil` when no guide is registered under it.
  static func destination(for guideID: String) -> AnyView? {
    destinations[guideID]?()
  }
}
