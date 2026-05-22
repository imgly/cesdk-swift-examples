import Foundation
import IMGLYEngine

@MainActor
func textAnimations(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.setDuration(page, duration: 10)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-textAnimations-createAnimation
  let text1 = try engine.block.create(.text)
  try engine.block.setPositionX(text1, value: 100)
  try engine.block.setPositionY(text1, value: 100)
  try engine.block.setWidth(text1, value: 600)
  try engine.block.setHeight(text1, value: 200)
  try engine.block.replaceText(text1, text: "Creating\nText\nAnimations")
  try engine.block.appendChild(to: page, child: text1)

  let baselineAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text1, animation: baselineAnimation)
  try engine.block.setDuration(baselineAnimation, duration: 2.0)
  // highlight-textAnimations-createAnimation

  // highlight-textAnimations-writingStyleLine
  let text2 = try engine.block.create(.text)
  try engine.block.setPositionX(text2, value: 700)
  try engine.block.setPositionY(text2, value: 100)
  try engine.block.setWidth(text2, value: 600)
  try engine.block.setHeight(text2, value: 200)
  try engine.block.replaceText(text2, text: "Line by line\nanimation\nfor text")
  try engine.block.appendChild(to: page, child: text2)

  let lineAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text2, animation: lineAnimation)
  try engine.block.setDuration(lineAnimation, duration: 2.0)
  try engine.block.setEnum(lineAnimation, property: "textAnimationWritingStyle", value: "Line")
  try engine.block.setEnum(lineAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-textAnimations-writingStyleLine

  // highlight-textAnimations-writingStyleWord
  let text3 = try engine.block.create(.text)
  try engine.block.setPositionX(text3, value: 1300)
  try engine.block.setPositionY(text3, value: 100)
  try engine.block.setWidth(text3, value: 600)
  try engine.block.setHeight(text3, value: 200)
  try engine.block.replaceText(text3, text: "Animate word by word for emphasis")
  try engine.block.appendChild(to: page, child: text3)

  let wordAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text3, animation: wordAnimation)
  try engine.block.setDuration(wordAnimation, duration: 2.5)
  try engine.block.setEnum(wordAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setEnum(wordAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-textAnimations-writingStyleWord

  // highlight-textAnimations-writingStyleCharacter
  let text4 = try engine.block.create(.text)
  try engine.block.setPositionX(text4, value: 100)
  try engine.block.setPositionY(text4, value: 400)
  try engine.block.setWidth(text4, value: 600)
  try engine.block.setHeight(text4, value: 200)
  try engine.block.replaceText(text4, text: "Character by character for typewriter effect")
  try engine.block.appendChild(to: page, child: text4)

  let characterAnimation = try engine.block.createAnimation(.baseline)
  try engine.block.setInAnimation(text4, animation: characterAnimation)
  try engine.block.setDuration(characterAnimation, duration: 3.0)
  try engine.block.setEnum(characterAnimation, property: "textAnimationWritingStyle", value: "Character")
  try engine.block.setEnum(characterAnimation, property: "animationEasing", value: "Linear")
  // highlight-textAnimations-writingStyleCharacter

  // highlight-textAnimations-overlapSequential
  let text5 = try engine.block.create(.text)
  try engine.block.setPositionX(text5, value: 700)
  try engine.block.setPositionY(text5, value: 400)
  try engine.block.setWidth(text5, value: 600)
  try engine.block.setHeight(text5, value: 200)
  try engine.block.replaceText(text5, text: "Sequential animation with zero overlap")
  try engine.block.appendChild(to: page, child: text5)

  let sequentialAnimation = try engine.block.createAnimation(.pan)
  try engine.block.setInAnimation(text5, animation: sequentialAnimation)
  try engine.block.setDuration(sequentialAnimation, duration: 2.0)
  try engine.block.setEnum(sequentialAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setFloat(sequentialAnimation, property: "textAnimationOverlap", value: 0.0)
  try engine.block.setEnum(sequentialAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-textAnimations-overlapSequential

  // highlight-textAnimations-overlapCascading
  let text6 = try engine.block.create(.text)
  try engine.block.setPositionX(text6, value: 1300)
  try engine.block.setPositionY(text6, value: 400)
  try engine.block.setWidth(text6, value: 600)
  try engine.block.setHeight(text6, value: 200)
  try engine.block.replaceText(text6, text: "Cascading animation with partial overlap")
  try engine.block.appendChild(to: page, child: text6)

  let cascadingAnimation = try engine.block.createAnimation(.pan)
  try engine.block.setInAnimation(text6, animation: cascadingAnimation)
  try engine.block.setDuration(cascadingAnimation, duration: 1.5)
  try engine.block.setEnum(cascadingAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setFloat(cascadingAnimation, property: "textAnimationOverlap", value: 0.4)
  try engine.block.setEnum(cascadingAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-textAnimations-overlapCascading

  // highlight-textAnimations-durationEasing
  let text7 = try engine.block.create(.text)
  try engine.block.setPositionX(text7, value: 100)
  try engine.block.setPositionY(text7, value: 700)
  try engine.block.setWidth(text7, value: 1200)
  try engine.block.setHeight(text7, value: 200)
  try engine.block.replaceText(text7, text: "Combine writing style, overlap, duration, and easing")
  try engine.block.appendChild(to: page, child: text7)

  let combinedAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setInAnimation(text7, animation: combinedAnimation)
  try engine.block.setEnum(combinedAnimation, property: "textAnimationWritingStyle", value: "Word")
  try engine.block.setFloat(combinedAnimation, property: "textAnimationOverlap", value: 0.3)
  try engine.block.setDuration(combinedAnimation, duration: 1.5)
  try engine.block.setEnum(combinedAnimation, property: "animationEasing", value: "EaseInOut")

  let writingStyleOptions = try engine.block.getEnumValues(ofProperty: "textAnimationWritingStyle")
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-textAnimations-durationEasing

  _ = writingStyleOptions
  _ = easingOptions
}
