import Foundation
import IMGLYEngine

@MainActor
func createAnimations(engine: Engine) async throws {
  // highlight-setup
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
  // highlight-setup

  // highlight-createAnimations-checkSupport
  guard try engine.block.supportsAnimation(block) else {
    return
  }

  let slideIn = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block, animation: slideIn)
  try engine.block.setDuration(slideIn, duration: 1.2)
  // highlight-createAnimations-checkSupport

  // highlight-createAnimations-entranceAnimation
  try engine.block.setEnum(slideIn, property: "animationEasing", value: "EaseOut")
  try engine.block.setFloat(slideIn, property: "animation/slide/direction", value: 1.5 * .pi)
  // highlight-createAnimations-entranceAnimation

  // highlight-createAnimations-exitAnimation
  let fadeOut = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block, animation: fadeOut)
  try engine.block.setDuration(fadeOut, duration: 1.0)
  try engine.block.setEnum(fadeOut, property: "animationEasing", value: "EaseIn")
  // highlight-createAnimations-exitAnimation

  // highlight-createAnimations-loopAnimation
  let pulsatingLoop = try engine.block.createAnimation(.pulsatingLoop)
  try engine.block.setLoopAnimation(block, animation: pulsatingLoop)
  try engine.block.setDuration(pulsatingLoop, duration: 1.5)
  // highlight-createAnimations-loopAnimation

  // highlight-createAnimations-animationProperties
  let slideProperties = try engine.block.findAllProperties(slideIn)
  print("Slide animation properties: \(slideProperties)")

  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  print("Available easing options: \(easingOptions)")
  // highlight-createAnimations-animationProperties

  // highlight-createAnimations-textAnimation
  let text = try engine.block.create(.text)
  try engine.block.setPositionX(text, value: 100)
  try engine.block.setPositionY(text, value: 400)
  try engine.block.setWidth(text, value: 600)
  try engine.block.setHeight(text, value: 100)
  try engine.block.replaceText(text, text: "Entrance • Exit • Loop")
  try engine.block.appendChild(to: page, child: text)

  let textAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setInAnimation(text, animation: textAnimation)
  try engine.block.setDuration(textAnimation, duration: 1.5)
  try engine.block.setEnum(textAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setFloat(textAnimation, property: "textAnimationOverlap", value: 0.3)
  // highlight-createAnimations-textAnimation

  // highlight-createAnimations-manageLifecycle
  let currentIn = try engine.block.getInAnimation(block)
  let currentOut = try engine.block.getOutAnimation(block)
  let currentLoop = try engine.block.getLoopAnimation(block)
  print("Animation IDs — In: \(currentIn), Out: \(currentOut), Loop: \(currentLoop)")

  if currentIn != 0 {
    try engine.block.destroy(currentIn)
    let zoomIn = try engine.block.createAnimation(.zoom)
    try engine.block.setInAnimation(block, animation: zoomIn)
    try engine.block.setDuration(zoomIn, duration: 0.8)
  }
  // highlight-createAnimations-manageLifecycle
}
