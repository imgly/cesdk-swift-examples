import Foundation
import IMGLYEngine

@MainActor
func editAnimations(engine: Engine) async throws {
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

  let slideAnimation = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block, animation: slideAnimation)
  try engine.block.setDuration(slideAnimation, duration: 1.0)

  let fadeOutAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block, animation: fadeOutAnimation)

  let breathingLoop = try engine.block.createAnimation(.breathingLoop)
  try engine.block.setLoopAnimation(block, animation: breathingLoop)
  // highlight-setup

  // highlight-editAnimations-retrieveAnimations
  let inAnimation = try engine.block.getInAnimation(block)
  let outAnimation = try engine.block.getOutAnimation(block)
  let loopAnimation = try engine.block.getLoopAnimation(block)
  let inType = try engine.block.getType(inAnimation)
  let outType = try engine.block.getType(outAnimation)
  // highlight-editAnimations-retrieveAnimations

  // highlight-editAnimations-readProperties
  let currentDuration = try engine.block.getDuration(inAnimation)
  let currentEasing = try engine.block.getEnum(inAnimation, property: "animationEasing")
  let allProperties = try engine.block.findAllProperties(inAnimation)
  // highlight-editAnimations-readProperties

  // highlight-editAnimations-modifyDuration
  try engine.block.setDuration(inAnimation, duration: 0.8)
  try engine.block.setDuration(loopAnimation, duration: 2.0)
  // highlight-editAnimations-modifyDuration

  // highlight-editAnimations-changeEasing
  try engine.block.setEnum(inAnimation, property: "animationEasing", value: "EaseOut")
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-editAnimations-changeEasing

  // highlight-editAnimations-adjustProperties
  try engine.block.setFloat(
    inAnimation,
    property: "animation/slide/direction",
    value: .pi,
  )
  let direction = try engine.block.getFloat(inAnimation, property: "animation/slide/direction")
  // highlight-editAnimations-adjustProperties

  // highlight-editAnimations-replaceAnimation
  let currentIn = try engine.block.getInAnimation(block)
  try engine.block.destroy(currentIn)
  let zoomAnimation = try engine.block.createAnimation(.zoom)
  try engine.block.setInAnimation(block, animation: zoomAnimation)
  try engine.block.setDuration(zoomAnimation, duration: 0.6)
  try engine.block.setEnum(zoomAnimation, property: "animationEasing", value: "EaseInOut")
  // highlight-editAnimations-replaceAnimation

  // highlight-editAnimations-removeAnimation
  let currentLoop = try engine.block.getLoopAnimation(block)
  try engine.block.destroy(currentLoop)
  // Destroying a design block also destroys all its attached animations
  // try engine.block.destroy(block)
  // highlight-editAnimations-removeAnimation
}
