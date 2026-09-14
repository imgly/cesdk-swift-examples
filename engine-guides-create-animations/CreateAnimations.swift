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

  let slideAnimation = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block, animation: slideAnimation)
  try engine.block.setDuration(slideAnimation, duration: 1.0)
  // highlight-createAnimations-checkSupport

  // highlight-createAnimations-entranceAnimation
  let fadeIn = try engine.block.createAnimation(.fade)
  try engine.block.destroy(try engine.block.getInAnimation(block))
  try engine.block.setInAnimation(block, animation: fadeIn)
  try engine.block.setDuration(fadeIn, duration: 0.8)
  try engine.block.setEnum(fadeIn, property: "animationEasing", value: "EaseOut")
  // highlight-createAnimations-entranceAnimation

  // highlight-createAnimations-exitAnimation
  let fadeOut = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block, animation: fadeOut)
  try engine.block.setDuration(fadeOut, duration: 0.6)
  try engine.block.setEnum(fadeOut, property: "animationEasing", value: "EaseIn")
  // highlight-createAnimations-exitAnimation

  // highlight-createAnimations-loopAnimation
  let pulsatingLoop = try engine.block.createAnimation(.pulsatingLoop)
  try engine.block.setLoopAnimation(block, animation: pulsatingLoop)
  try engine.block.setDuration(pulsatingLoop, duration: 2.0)
  // highlight-createAnimations-loopAnimation

  // highlight-createAnimations-animationProperties
  let allProperties = try engine.block.findAllProperties(fadeIn)
  try engine.block.setEnum(fadeIn, property: "animationEasing", value: "EaseInOut")

  let slideIn = try engine.block.createAnimation(.slide)
  try engine.block.destroy(try engine.block.getInAnimation(block))
  try engine.block.setInAnimation(block, animation: slideIn)
  try engine.block.setDuration(slideIn, duration: 1.0)
  try engine.block.setFloat(slideIn, property: "animation/slide/direction", value: 0.5 * .pi)
  // highlight-createAnimations-animationProperties

  // highlight-createAnimations-textAnimation
  let text = try engine.block.create(.text)
  try engine.block.setPositionX(text, value: 100)
  try engine.block.setPositionY(text, value: 400)
  try engine.block.setWidth(text, value: 600)
  try engine.block.setHeight(text, value: 100)
  try engine.block.replaceText(text, text: "Animated text with word-by-word reveal")
  try engine.block.appendChild(to: page, child: text)

  let baselineAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text, animation: baselineAnimation)
  try engine.block.setDuration(baselineAnimation, duration: 2.0)
  try engine.block.setEnum(baselineAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setFloat(baselineAnimation, property: "textAnimationOverlap", value: 0.4)
  // highlight-createAnimations-textAnimation

  // highlight-createAnimations-manageLifecycle
  let currentIn = try engine.block.getInAnimation(block)
  let currentOut = try engine.block.getOutAnimation(block)
  let currentLoop = try engine.block.getLoopAnimation(block)
  let inType = try engine.block.getType(currentIn)

  try engine.block.destroy(currentIn)
  let zoomIn = try engine.block.createAnimation(.zoom)
  try engine.block.setInAnimation(block, animation: zoomIn)
  try engine.block.setDuration(zoomIn, duration: 0.5)

  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-createAnimations-manageLifecycle
}
