import Foundation
import IMGLYEngine

struct TextAnimatorsGuideResult {
  let textSupportsAnimators: Bool
  let pageSupportsAnimators: Bool
  let reveal: DesignBlockID
  let highlight: DesignBlockID
  let wave: DesignBlockID
  let orderAfterInsert: [DesignBlockID]
  let highlightIsValidAfterRemove: Bool
  let orderAfterReappend: [DesignBlockID]
  let countdownKeyframeCount: Int
  let errorCode: EngineErrorCode?
  let pngData: Data
}

@MainActor
func textAnimators(engine: Engine) async throws -> TextAnimatorsGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-textAnimators-createText
  // A 5 second headline in the middle of the page
  let text = try engine.block.create(.text)
  try engine.block.replaceText(text, text: "Text animators move every letter")
  try engine.block.setTextFontSize(text, fontSize: 120)
  try engine.block.setEnum(text, property: "text/horizontalAlignment", value: "Center")
  try engine.block.setWidth(text, value: 1600)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.setPositionX(text, value: 160)
  try engine.block.setPositionY(text, value: 380)
  try engine.block.appendChild(to: page, child: text)
  try engine.block.setDuration(text, duration: 5)
  // highlight-textAnimators-createText

  // highlight-textAnimators-createAnimator
  let textSupportsAnimators = try engine.block.supportsTextAnimators(text) // true
  let pageSupportsAnimators = try engine.block.supportsTextAnimators(page) // false

  // The covered glyphs sit 60 units lower and are hidden
  let reveal = try engine.block.createTextAnimator()
  try engine.block.setFloat(reveal, property: "text_animator/positionY", value: 60)
  try engine.block.setBool(reveal, property: "text_animator/opacityEnabled", value: true)
  try engine.block.setFloat(reveal, property: "text_animator/opacity", value: 0)
  try engine.block.appendTextAnimator(text, animatorID: reveal)
  // highlight-textAnimators-createAnimator

  // highlight-textAnimators-keyframedReveal
  // Move the start of the range from 0 to 1 in the first half of the
  // text's duration. The uncovered glyphs rise and fade in, left to right.
  try engine.block.setKeyframes(reveal, property: "text_animator/selectorStart", keyframes: [
    Keyframe(time: 0, value: .float(0), easing: .preset(.easeOut)),
    Keyframe(time: 0.5, value: .float(1)),
  ])
  // highlight-textAnimators-keyframedReveal

  // highlight-textAnimators-rangeSelector
  // Cover the second word only: words are counted from 0 in index units
  let highlight = try engine.block.createTextAnimator()
  try engine.block.setEnum(highlight, property: "text_animator/selectorBasedOn", value: "Words")
  try engine.block.setEnum(highlight, property: "text_animator/selectorUnits", value: "Index")
  try engine.block.setFloat(highlight, property: "text_animator/selectorStart", value: 1)
  try engine.block.setFloat(highlight, property: "text_animator/selectorEnd", value: 2)

  // Color and scale the covered glyphs
  try engine.block.setBool(highlight, property: "text_animator/fillColorEnabled", value: true)
  try engine.block.setColor(
    highlight,
    property: "text_animator/fillColor",
    color: .rgba(r: 1, g: 0.5, b: 0, a: 1),
  )
  try engine.block.setFloat(highlight, property: "text_animator/scaleX", value: 1.2)
  try engine.block.setFloat(highlight, property: "text_animator/scaleY", value: 1.2)
  // highlight-textAnimators-rangeSelector

  // highlight-textAnimators-stackOrder
  // Insert the highlight before the reveal
  try engine.block.insertTextAnimator(text, animatorID: highlight, index: 0)
  let orderAfterInsert = try engine.block.getTextAnimators(text) // [highlight, reveal]
  // highlight-textAnimators-stackOrder

  // highlight-textAnimators-wave
  // A triangle covers a quarter of the characters and peaks in its middle
  let wave = try engine.block.createTextAnimator()
  try engine.block.setEnum(wave, property: "text_animator/selectorShape", value: "Triangle")
  try engine.block.setFloat(wave, property: "text_animator/selectorEnd", value: 0.25)
  try engine.block.setFloat(wave, property: "text_animator/positionY", value: -40)
  try engine.block.setFloat(wave, property: "text_animator/rotation", value: -0.2)

  // Move the range across the text over the whole duration
  try engine.block.setKeyframes(wave, property: "text_animator/selectorOffset", keyframes: [
    Keyframe(time: 0, value: .float(-0.25)),
    Keyframe(time: 1, value: .float(1)),
  ])
  try engine.block.appendTextAnimator(text, animatorID: wave)
  // highlight-textAnimators-wave

  // highlight-textAnimators-remove
  // Remove the highlight at index 0. The animator stays valid.
  try engine.block.removeTextAnimator(text, index: 0)
  let highlightIsValidAfterRemove = engine.block.isValid(highlight) // true

  // Append it again so that it applies last
  try engine.block.appendTextAnimator(text, animatorID: highlight)
  let orderAfterReappend = try engine.block.getTextAnimators(text) // [reveal, wave, highlight]
  print(orderAfterInsert, highlightIsValidAfterRemove, orderAfterReappend)
  // highlight-textAnimators-remove

  // highlight-textAnimators-textContent
  // A second text block counts down from 3 to 1
  let countdown = try engine.block.create(.text)
  try engine.block.replaceText(countdown, text: "3")
  try engine.block.setTextFontSize(countdown, fontSize: 160)
  try engine.block.setWidthMode(countdown, mode: .auto)
  try engine.block.setHeightMode(countdown, mode: .auto)
  try engine.block.setPositionX(countdown, value: 900)
  try engine.block.setPositionY(countdown, value: 700)
  try engine.block.appendChild(to: page, child: countdown)
  try engine.block.setDuration(countdown, duration: 5)

  try engine.block.setKeyframes(countdown, property: "text/text", keyframes: [
    Keyframe(time: 0, value: .discrete(.string("3"))),
    Keyframe(time: 0.33, value: .discrete(.string("2"))),
    Keyframe(time: 0.67, value: .discrete(.string("1"))),
  ])
  // highlight-textAnimators-textContent

  // highlight-textAnimators-errors
  var errorCode: EngineErrorCode?
  do {
    // The reveal already belongs to the headline
    try engine.block.appendTextAnimator(countdown, animatorID: reveal)
  } catch let error as EngineError {
    errorCode = error.catalogCode
    print(errorCode == .blockTextAnimatorAlreadyAttached) // true
  }
  // highlight-textAnimators-errors

  // highlight-textAnimators-export
  // Export the frame at 2 seconds, during the reveal
  try engine.block.setPlaybackTime(page, time: 2)
  let pngData = try await engine.block.export(page, mimeType: .png)
  // highlight-textAnimators-export

  let countdownKeyframeCount = try engine.block.getKeyframes(countdown, property: "text/text").count
  return TextAnimatorsGuideResult(
    textSupportsAnimators: textSupportsAnimators,
    pageSupportsAnimators: pageSupportsAnimators,
    reveal: reveal,
    highlight: highlight,
    wave: wave,
    orderAfterInsert: orderAfterInsert,
    highlightIsValidAfterRemove: highlightIsValidAfterRemove,
    orderAfterReappend: orderAfterReappend,
    countdownKeyframeCount: countdownKeyframeCount,
    errorCode: errorCode,
    pngData: pngData,
  )
}
