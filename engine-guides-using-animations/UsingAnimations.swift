import Foundation
import IMGLYEngine

@MainActor
func usingAnimations(engine: Engine) async throws {
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

  // highlight-supportsAnimation
  guard try engine.block.supportsAnimation(block) else {
    return
  }
  // highlight-supportsAnimation

  // highlight-createAnimation
  let slideInAnimation = try engine.block.createAnimation(.slide)
  let breathingLoopAnimation = try engine.block.createAnimation(.breathingLoop)
  let fadeOutAnimation = try engine.block.createAnimation(.fade)
  // highlight-createAnimation
  // highlight-setInAnimation
  try engine.block.setInAnimation(block, animation: slideInAnimation)
  // highlight-setInAnimation
  // highlight-setLoopAnimation
  try engine.block.setLoopAnimation(block, animation: breathingLoopAnimation)
  // highlight-setLoopAnimation
  // highlight-setOutAnimation
  try engine.block.setOutAnimation(block, animation: fadeOutAnimation)
  // highlight-setOutAnimation
  // highlight-getAnimation
  let animation = try engine.block.getLoopAnimation(block)
  let animationType = try engine.block.getType(animation)
  // highlight-getAnimation

  // highlight-replaceAnimation
  let squeezeLoopAnimation = try engine.block.createAnimation(.squeezeLoop)
  try engine.block.destroy(engine.block.getLoopAnimation(block))
  try engine.block.setLoopAnimation(block, animation: squeezeLoopAnimation)
  // The following line would also destroy all currently attached animations
  // try engine.block.destroy(block)
  // highlight-replaceAnimation

  // highlight-getProperties
  let allAnimationProperties = try engine.block.findAllProperties(slideInAnimation)
  // highlight-getProperties
  // highlight-modifyProperties
  try engine.block.setFloat(slideInAnimation, property: "animation/slide/direction", value: 0.5 * .pi)
  // highlight-modifyProperties
  // highlight-changeDuration
  try engine.block.setDuration(slideInAnimation, duration: 0.6)
  // highlight-changeDuration
  // highlight-changeEasing
  try engine.block.setEnum(slideInAnimation, property: "animationEasing", value: "EaseOut")
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-changeEasing
}
