@testable import Guides
@testable import IMGLYEngine
import Testing

@MainActor
final class GuidesTest {
  var engine: Engine!

  @MainActor
  init() async throws {
    engine = try await Engine(
      context: .offscreen(size: .init(width: 100, height: 100)),
      audioContext: .none,
      license: Secrets.offlineLicenseKey,
    )
  }

  @MainActor
  deinit {
    engine.notLeaked()
    engine = nil
  }

  @Test func testArchitecture() async throws {
    try await architecture(engine: engine)
  }

  @Test func testBoolOps() async throws {
    try await boolOps(engine: engine)
  }

  @Test func testColors() async throws {
    try await colors(engine: engine)
  }

  @Test func testColorsAdjust() async throws {
    try await colorsAdjust(engine: engine)
  }

  @Test func testColorsBasics() async throws {
    try await colorsBasics(engine: engine)
  }

  @Test func testCmykColors() async throws {
    try await cmykColors(engine: engine)
  }

  @Test func testConceptsAssets() async throws {
    try await conceptsAssets(engine: engine)
  }

  @Test func testConceptsBlocks() async throws {
    try await conceptsBlocks(engine: engine)
  }

  @Test func testConversionToPng() async throws {
    try await conversionToPng(engine: engine)
  }

  @Test func testUnderlayer() async throws {
    try await underlayer(engine: engine)
  }

  @Test func testCreateCompositionProgrammatic() async throws {
    try await createCompositionProgrammatic(engine: engine)
  }

  @Test func testCreateSceneFromImageBlob() async throws {
    try await createSceneFromImageBlob(engine: engine)
  }

  @Test func testCreateSceneFromImageURL() async throws {
    try await createSceneFromImageURL(engine: engine)
  }

  @Test func testCreateSceneFromScratch() async throws {
    try await createSceneFromScratch(engine: engine)
  }

  @Test func testCreateSceneFromVideoURL() async throws {
    try await createSceneFromVideoURL(engine: engine)
  }

  @Test func testCustomAssetSource() async throws {
    try await customAssetSource(engine: engine)
  }

  @Test func testCutouts() async throws {
    try await cutouts(engine: engine)
  }

  @Test func conversionToBase64() async throws {
    try await toBase64(engine: engine)
  }

  @Test func testExportingBlocks() async throws {
    try await exportingBlocks(engine: engine)
  }

  @Test func testLoadSceneFromBlob() async throws {
    try await loadSceneFromBlob(engine: engine)
  }

  @Test func testLockDesign() async throws {
    try await lockDesign(engine: engine)
  }

  @Test func testLoadSceneFromRemote() async throws {
    try await loadSceneFromRemote(engine: engine)
  }

  @Test func testLoadSceneFromString() async throws {
    try await loadSceneFromString(engine: engine)
  }

  @Test func testModifyingScenes() async throws {
    try await modifyingScenes(engine: engine)
  }

  @Test func testMultiPage() async throws {
    try await multiPage(engine: engine)
  }

  @Test func testPages() async throws {
    try await pages(engine: engine)
  }

  @Test func testPositionAndAlign() async throws {
    try await positionAndAlign(engine: engine)
  }

  @Test func testSaveSceneToArchive() async throws {
    await withKnownIssue("Flakiness when uploading to https://example.com.", isIntermittent: true) {
      try await saveSceneToArchive(engine: engine)
    }
  }

  @Test func testSaveSceneToBlob() async throws {
    await withKnownIssue("Flakiness when uploading to https://example.com.", isIntermittent: true) {
      try await saveSceneToBlob(engine: engine)
    }
  }

  @Test func testSaveSceneToString() async throws {
    try await saveSceneToString(engine: engine)
  }

  @Test func testSaveSceneToStringWithPersistenceCallback() async throws {
    await withKnownIssue("Flakiness when uploading to https://example.com.", isIntermittent: true) {
      try await saveSceneToStringWithPersistenceCallback(engine: engine)
    }
  }

  @Test func testScopes() async throws {
    try await scopes(engine: engine)
  }

  @Test func testSpotColors() async throws {
    try await spotColors(engine: engine)
  }

  @Test func testStoreMetadata() async throws {
    try await storeMetadata(engine: engine)
  }

  @Test func testTemplating() async throws {
    await withKnownIssue("Flakiness when loading from remote URL.", isIntermittent: true) {
      try await templating(engine: engine)
    }
  }

  @Test func testTextEnumerations() async throws {
    try await textEnumerations(engine: engine)
  }

  @Test func testToBlob() async throws {
    try await toBlob(engine: engine)
  }

  @Test func testTextProperties() async throws {
    try await textProperties(engine: engine)
  }

  @Test func testTextWithEmojis() async throws {
    try await textWithEmojis(engine: engine)
  }

  @Test func testUndoAndHistory() async throws {
    try await undoAndHistory(engine: engine)
  }

  @Test func testUriResolver() async throws {
    try await uriResolver(engine: engine)
  }

  // Camera requires a device for testing.
//  @Test func testUsingCamera() async throws {
//    try await usingCamera(engine: engine)
//  }

  @Test func testUsingAnimations() async throws {
    try await usingAnimations(engine: engine)
  }

  @Test func testTextAnimations() async throws {
    try await textAnimations(engine: engine)
  }

  @Test func testEditorState() async throws {
    try await editorState(engine: engine)
  }

  @Test func testEditAnimations() async throws {
    try await editAnimations(engine: engine)
  }

  @Test func testEditingWorkflow() async throws {
    try await editingWorkflow(engine: engine)
  }

  @Test func testAnimationTypes() async throws {
    try await animationTypes(engine: engine)
  }

  @Test func testCreateAnimations() async throws {
    try await createAnimations(engine: engine)
  }

  @Test func testUsingEffects() async throws {
    try await usingEffects(engine: engine)
  }

  @Test func testUsingFills() async throws {
    try await usingFills(engine: engine)
  }

  @Test func testUsingShapes() async throws {
    try await usingShapes(engine: engine)
  }

  @Test func testEditVideo() async throws {
    try await editVideo(engine: engine)
  }

  @Test func testEvents() async throws {
    try await events(engine: engine)
  }

  @Test func testEditVideoCaptions() async throws {
    try await editVideoCaptions(engine: engine)
  }

  @Test func testSourceSets() async throws {
    try await sourceSets(engine: engine)
  }

  @Test func testBuffers() throws {
    try buffers(engine: engine)
  }

  @Test func customLutFilters() async throws {
    try await customLutFilter(engine: engine)
  }

  @Test func testProductVariations() async throws {
    try await productVariations(engine: engine)
  }

  @Test func testDesignUnits() async throws {
    try await designUnits(engine: engine)
  }

  @Test func testResources() async throws {
    try await resources(engine: engine)
  }
}
