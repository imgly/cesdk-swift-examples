import IMGLYEngine

@MainActor
func p3Colors(engine: Engine) async throws {
  // Demo scaffolding: a minimal scene to exercise the rendering pipeline.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-p3Colors-checkSupport
  let p3IsSupported = try engine.editor.supportsP3()
  // highlight-p3Colors-checkSupport

  // highlight-p3Colors-checkSupportThrowing
  do {
    try engine.editor.checkP3Support()
  } catch {
    print("P3 unavailable: \(error.localizedDescription)")
    // Fall back to sRGB.
  }
  // highlight-p3Colors-checkSupportThrowing

  // highlight-p3Colors-enable
  if p3IsSupported {
    try engine.editor.setSettingBool("features/p3WorkingColorSpace", value: true)
  }
  // highlight-p3Colors-enable

  // highlight-p3Colors-gracefulFallback
  do {
    try engine.editor.checkP3Support()
    try engine.editor.setSettingBool("features/p3WorkingColorSpace", value: true)
  } catch {
    print("Staying on sRGB: \(error.localizedDescription)")
  }
  // highlight-p3Colors-gracefulFallback
}
