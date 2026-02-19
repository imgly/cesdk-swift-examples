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

  @Test func testBoolOps() async throws {
    try await boolOps(engine: engine)
  }

  @Test func testColors() async throws {
    try await colors(engine: engine)
  }

  @Test func testUnderlayer() async throws {
    try await underlayer(engine: engine)
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

  @Test func testExportingBlocks() async throws {
    try await exportingBlocks(engine: engine)
  }

  @Test func testLoadSceneFromBlob() async throws {
    try await loadSceneFromBlob(engine: engine)
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

  @Test func testTextProperties() async throws {
    try await textProperties(engine: engine)
  }

  @Test func testTextWithEmojis() async throws {
    try await textWithEmojis(engine: engine)
  }

  @Test func testUriResolver() async throws {
    try await uriResolver(engine: engine)
  }

  // Camera requires a device for testing.
//  @Test func testUsingCamera() async throws {
//    try await usingCamera(engine: engine)
//  }

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
}
