import Foundation
import IMGLYEngine

@MainActor
func baseAnimations(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(block, value: 100)
  try engine.block.setPositionY(block, value: 50)
  try engine.block.setWidth(block, value: 300)
  try engine.block.setHeight(block, value: 300)
  try engine.block.appendChild(to: page, child: block)
  let fill = try engine.block.createFill(.image)
  try engine.block.setString(
    fill,
    property: "fill/image/imageFileURI",
    value: "https://img.ly/static/ubq_samples/sample_1.jpg",
  )
  try engine.block.setFill(block, fill: fill)

  // highlight-baseAnim-supports
  guard try engine.block.supportsAnimation(block) else {
    return
  }
  let slideIn = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block, animation: slideIn)
  try engine.block.setDuration(slideIn, duration: 1.0)
  // highlight-baseAnim-supports

  // highlight-baseAnim-entrance
  let fadeIn = try engine.block.createAnimation(.fade)
  try engine.block.destroy(engine.block.getInAnimation(block))
  try engine.block.setInAnimation(block, animation: fadeIn)
  try engine.block.setDuration(fadeIn, duration: 0.8)
  try engine.block.setEnum(fadeIn, property: "animationEasing", value: "EaseOut")
  // highlight-baseAnim-entrance

  // highlight-baseAnim-exit
  let fadeOut = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block, animation: fadeOut)
  try engine.block.setDuration(fadeOut, duration: 0.6)
  // highlight-baseAnim-exit

  // highlight-baseAnim-loop
  let breathing = try engine.block.createAnimation(.breathingLoop)
  try engine.block.setLoopAnimation(block, animation: breathing)
  try engine.block.setDuration(breathing, duration: 2.0)
  // highlight-baseAnim-loop

  // highlight-baseAnim-properties
  let slideFromTop = try engine.block.createAnimation(.slide)
  let slideProperties = try engine.block.findAllProperties(slideFromTop)
  print("Slide animation properties: \(slideProperties)")
  try engine.block.setFloat(slideFromTop, property: "animation/slide/direction", value: 0.5 * .pi)
  // highlight-baseAnim-properties

  // highlight-baseAnim-manage
  let currentIn = try engine.block.getInAnimation(block)
  let currentLoop = try engine.block.getLoopAnimation(block)
  let currentOut = try engine.block.getOutAnimation(block)
  print("Animation IDs — In: \(currentIn), Loop: \(currentLoop), Out: \(currentOut)")

  if currentLoop != 0 {
    try engine.block.destroy(currentLoop)
  }
  let squeeze = try engine.block.createAnimation(.squeezeLoop)
  try engine.block.setLoopAnimation(block, animation: squeeze)
  // Destroying a design block also destroys all its attached animations:
  // try engine.block.destroy(block)
  // highlight-baseAnim-manage

  // highlight-baseAnim-easing
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  print("Available easing options: \(easingOptions)")
  try engine.block.setEnum(fadeIn, property: "animationEasing", value: "EaseInOut")
  // highlight-baseAnim-easing

  try engine.block.destroy(slideFromTop)
}
