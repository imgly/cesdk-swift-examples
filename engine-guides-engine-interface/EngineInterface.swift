import IMGLYEngine

// highlight-engineInterface-namespaces
@MainActor
func engineInterface(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)

  let json = try await engine.scene.saveToString()
  try await engine.scene.load(from: json)
}

// highlight-engineInterface-namespaces

// highlight-engineInterface-offscreen
@MainActor
func makeOffscreenEngine(license: String) async throws -> Engine {
  try await Engine(
    context: .offscreen(size: .init(width: 1024, height: 1024)),
    audioContext: .none,
    license: license,
  )
}

// highlight-engineInterface-offscreen
