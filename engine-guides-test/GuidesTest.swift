@testable import Guides
@testable import IMGLYEngine
import XCTest

@MainActor
class GuidesTest: XCTestCase {
  var engine: Engine!

  @MainActor
  override func setUp() async throws {
    engine = Engine(context: .offscreen(size: .init(width: 100, height: 100)), audioContext: .none)
  }

  @MainActor
  override func tearDown() async throws {
    engine.notLeaked()
    engine = nil
  }

  func testCreateSceneFromScratch() throws {
    try createSceneFromScratch(engine: engine)
  }

  func testCreateSceneFromImageURL() async throws {
    try await createSceneFromImageURL(engine: engine)
  }

  func testCreateSceneFromImageBlob() async throws {
    try await createSceneFromImageBlob(engine: engine)
  }

  func testCreateSceneFromVideoURL() async throws {
    try await createSceneFromVideoURL(engine: engine)
  }

  func testLoadSceneFromString() async throws {
    try await loadSceneFromString(engine: engine)
  }

  func testLoadSceneFromBlob() async throws {
    try await loadSceneFromBlob(engine: engine)
  }

  func testLoadSceneFromRemote() async throws {
    try await loadSceneFromRemote(engine: engine)
  }

  func testSaveSceneToString() async throws {
    try await saveSceneToString(engine: engine)
  }

  func testSaveSceneToBlob() async throws {
    try await saveSceneToBlob(engine: engine)
  }

  func testSaveSceneToArchive() async throws {
    try await saveSceneToArchive(engine: engine)
  }

  func testModifyingScenes() async throws {
    try await modifyingScenes(engine: engine)
  }

  func testExportingBlocks() async throws {
    try await exportingBlocks(engine: engine)
  }

  func testUsingFills() async throws {
    try await usingFills(engine: engine)
  }

  func testUsingEffects() async throws {
    try await usingEffects(engine: engine)
  }

  func testCustomAssetSource() async throws {
    try await customAssetSource(engine: engine)
  }

  func testURIResolution() async throws {
    try await URIResolver(engine: engine)
  }

  func testStoreMetadata() async throws {
    try await storeMetadata(engine: engine)
  }

  func testScopes() async throws {
    try await scopes(engine: engine)
  }

  func testSpotColors() async throws {
    try await spotColors(engine: engine)
  }

  func testEmojis() async throws {
    try await textWithEmojis(engine: engine)
  }

  func testTextProperties() async throws {
    try await textProperties(engine: engine)
  }

  func testCutouts() async throws {
    try await cutouts(engine: engine)
  }
}
