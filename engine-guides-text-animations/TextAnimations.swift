import Foundation
import IMGLYEngine

@MainActor
func textAnimations(engine: Engine) async throws {
  // highlight-setup
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)

  let text = try engine.block.create(.text)
  try engine.block.setPositionX(text, value: 100)
  try engine.block.setPositionY(text, value: 50)
  try engine.block.setWidth(text, value: 600)
  try engine.block.setHeight(text, value: 300)
  try engine.block.replaceText(text, text: "Hello World, this is a text animation example with multiple words.")
  try engine.block.appendChild(to: page, child: text)
  // highlight-setup

  // highlight-textAnimations-createAnimation
  let baselineAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text, animation: baselineAnimation)
  try engine.block.setDuration(baselineAnimation, duration: 2.0)
  // highlight-textAnimations-createAnimation

  // highlight-textAnimations-writingStyleLine
  try engine.block.setEnum(
    baselineAnimation,
    property: "textAnimationWritingStyle",
    value: "Line",
  )
  // highlight-textAnimations-writingStyleLine

  // highlight-textAnimations-writingStyleWord
  try engine.block.setEnum(
    baselineAnimation,
    property: "textAnimationWritingStyle",
    value: "Word",
  )
  // highlight-textAnimations-writingStyleWord

  // highlight-textAnimations-writingStyleCharacter
  try engine.block.setEnum(
    baselineAnimation,
    property: "textAnimationWritingStyle",
    value: "Character",
  )
  // highlight-textAnimations-writingStyleCharacter

  // highlight-textAnimations-overlapSequential
  try engine.block.setFloat(
    baselineAnimation,
    property: "textAnimationOverlap",
    value: 0.0,
  )
  // highlight-textAnimations-overlapSequential

  // highlight-textAnimations-overlapCascading
  try engine.block.setFloat(
    baselineAnimation,
    property: "textAnimationOverlap",
    value: 0.4,
  )
  // highlight-textAnimations-overlapCascading

  // highlight-textAnimations-durationEasing
  try engine.block.setDuration(baselineAnimation, duration: 1.5)
  try engine.block.setEnum(baselineAnimation, property: "animationEasing", value: "EaseOut")
  let writingStyleOptions = try engine.block.getEnumValues(ofProperty: "textAnimationWritingStyle")
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-textAnimations-durationEasing
}
