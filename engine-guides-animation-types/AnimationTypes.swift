import Foundation
import IMGLYEngine

@MainActor
func animationTypes(engine: Engine) async throws {
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

  // highlight-animationTypes-entranceSlide
  let slideAnimation = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block, animation: slideAnimation)
  try engine.block.setDuration(slideAnimation, duration: 1.0)
  try engine.block.setFloat(slideAnimation, property: "animation/slide/direction", value: .pi)
  try engine.block.setEnum(slideAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-animationTypes-entranceSlide

  try engine.block.destroy(try engine.block.getInAnimation(block))

  // highlight-animationTypes-entranceFade
  let fadeAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setInAnimation(block, animation: fadeAnimation)
  try engine.block.setDuration(fadeAnimation, duration: 0.8)
  try engine.block.setEnum(fadeAnimation, property: "animationEasing", value: "EaseInOut")
  // highlight-animationTypes-entranceFade

  try engine.block.destroy(try engine.block.getInAnimation(block))

  // highlight-animationTypes-entranceZoom
  let zoomAnimation = try engine.block.createAnimation(.zoom)
  try engine.block.setInAnimation(block, animation: zoomAnimation)
  try engine.block.setDuration(zoomAnimation, duration: 1.0)
  try engine.block.setBool(zoomAnimation, property: "animation/zoom/fade", value: true)
  // highlight-animationTypes-entranceZoom

  try engine.block.destroy(try engine.block.getInAnimation(block))

  // highlight-animationTypes-exitAnimation
  let wipeInAnimation = try engine.block.createAnimation(.wipe)
  try engine.block.setInAnimation(block, animation: wipeInAnimation)
  try engine.block.setDuration(wipeInAnimation, duration: 0.8)

  let fadeOutAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block, animation: fadeOutAnimation)
  try engine.block.setDuration(fadeOutAnimation, duration: 0.6)
  try engine.block.setEnum(fadeOutAnimation, property: "animationEasing", value: "EaseIn")
  // highlight-animationTypes-exitAnimation

  try engine.block.destroy(try engine.block.getInAnimation(block))
  try engine.block.destroy(try engine.block.getOutAnimation(block))

  // highlight-animationTypes-loopAnimation
  let breathingLoop = try engine.block.createAnimation(.breathingLoop)
  try engine.block.setLoopAnimation(block, animation: breathingLoop)
  try engine.block.setDuration(breathingLoop, duration: 2.0)
  // highlight-animationTypes-loopAnimation

  try engine.block.destroy(try engine.block.getLoopAnimation(block))

  // highlight-animationTypes-combinedAnimations
  let spinIn = try engine.block.createAnimation(.spin)
  try engine.block.setInAnimation(block, animation: spinIn)
  try engine.block.setDuration(spinIn, duration: 0.8)

  let blurOut = try engine.block.createAnimation(.blur)
  try engine.block.setOutAnimation(block, animation: blurOut)
  try engine.block.setDuration(blurOut, duration: 0.6)

  let swayLoop = try engine.block.createAnimation(.swayLoop)
  try engine.block.setLoopAnimation(block, animation: swayLoop)
  try engine.block.setDuration(swayLoop, duration: 1.5)
  // highlight-animationTypes-combinedAnimations

  // highlight-animationTypes-discoverProperties
  let animationProperties = try engine.block.findAllProperties(spinIn)
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-animationTypes-discoverProperties
}
