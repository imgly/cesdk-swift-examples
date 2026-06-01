import Foundation
import IMGLYEngine

@MainActor
func exportWithColorMask(engine: Engine) async throws {
  // Demo scaffolding: build a small scene with two graphic blocks so the
  // exported PNG visibly demonstrates color masking — a pure-red rectangle
  // (which the mask removes) and a blue ellipse (which survives).
  // In your app you would start from a scene already loaded into the editor.
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let registrationMark = try engine.block.create(.graphic)
  try engine.block.setShape(registrationMark, shape: engine.block.createShape(.rect))
  let redFill = try engine.block.createFill(.color)
  try engine.block.setColor(redFill, property: "fill/color/value", color: .rgba(r: 1.0, g: 0.0, b: 0.0, a: 1.0))
  try engine.block.setFill(registrationMark, fill: redFill)
  try engine.block.setPositionX(registrationMark, value: 50)
  try engine.block.setPositionY(registrationMark, value: 50)
  try engine.block.setWidth(registrationMark, value: 200)
  try engine.block.setHeight(registrationMark, value: 200)
  try engine.block.appendChild(to: page, child: registrationMark)

  let artwork = try engine.block.create(.graphic)
  try engine.block.setShape(artwork, shape: engine.block.createShape(.ellipse))
  let blueFill = try engine.block.createFill(.color)
  try engine.block.setColor(blueFill, property: "fill/color/value", color: .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0))
  try engine.block.setFill(artwork, fill: blueFill)
  try engine.block.setPositionX(artwork, value: 300)
  try engine.block.setPositionY(artwork, value: 100)
  try engine.block.setWidth(artwork, value: 400)
  try engine.block.setHeight(artwork, value: 400)
  try engine.block.appendChild(to: page, child: artwork)

  // highlight-exportWithColorMask-export
  let blobs = try await engine.block.exportWithColorMask(
    page,
    mimeType: .png,
    maskColorR: 1.0,
    maskColorG: 0.0,
    maskColorB: 0.0,
  )
  let maskedImage = blobs[0]
  let alphaMask = blobs[1]
  // highlight-exportWithColorMask-export

  // highlight-exportWithColorMask-write
  let exportsDirectory = FileManager.default.temporaryDirectory
  try maskedImage.write(to: exportsDirectory.appendingPathComponent("design.masked.png"))
  try alphaMask.write(to: exportsDirectory.appendingPathComponent("design.alpha.png"))
  // highlight-exportWithColorMask-write
}
