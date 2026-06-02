import Foundation
import IMGLYEngine

@MainActor
func animationTypes(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.appendChild(to: scene, child: page)

  let pageFill = try engine.block.createFill(.color)
  try engine.block.setColor(pageFill, property: "fill/color/value", r: 1, g: 1, b: 1, a: 1)
  try engine.block.setFill(page, fill: pageFill)

  let imageURLs = [
    "https://img.ly/static/ubq_samples/sample_1.jpg",
    "https://img.ly/static/ubq_samples/sample_2.jpg",
    "https://img.ly/static/ubq_samples/sample_3.jpg",
    "https://img.ly/static/ubq_samples/sample_4.jpg",
    "https://img.ly/static/ubq_samples/sample_5.jpg",
    "https://img.ly/static/ubq_samples/sample_6.jpg",
  ]

  // 2 columns × 3 rows grid layout for 6 demonstration blocks.
  let columns = 2
  let rows = 3
  let blockWidth: Float = 1920 / Float(columns) - 60
  let blockHeight: Float = 1080 / Float(rows) - 60

  func createImageBlock(index: Int) throws -> DesignBlockID {
    let graphic = try engine.block.create(.graphic)
    try engine.block.setShape(graphic, shape: engine.block.createShape(.rect))
    let imageFill = try engine.block.createFill(.image)
    try engine.block.setString(imageFill, property: "fill/image/imageFileURI", value: imageURLs[index])
    try engine.block.setFill(graphic, fill: imageFill)
    try engine.block.setWidth(graphic, value: blockWidth)
    try engine.block.setHeight(graphic, value: blockHeight)
    let column = index % columns
    let row = index / columns
    try engine.block.setPositionX(graphic, value: 30 + Float(column) * (blockWidth + 60))
    try engine.block.setPositionY(graphic, value: 30 + Float(row) * (blockHeight + 60))
    try engine.block.appendChild(to: page, child: graphic)
    return graphic
  }

  let block1 = try createImageBlock(index: 0)

  // highlight-animationTypes-entranceSlide
  let slideAnimation = try engine.block.createAnimation(.slide)
  try engine.block.setInAnimation(block1, animation: slideAnimation)
  try engine.block.setDuration(slideAnimation, duration: 1.0)
  try engine.block.setFloat(slideAnimation, property: "animation/slide/direction", value: .pi)
  try engine.block.setEnum(slideAnimation, property: "animationEasing", value: "EaseOut")
  // highlight-animationTypes-entranceSlide

  let block2 = try createImageBlock(index: 1)

  // highlight-animationTypes-entranceFade
  let fadeAnimation = try engine.block.createAnimation(.fade)
  try engine.block.setInAnimation(block2, animation: fadeAnimation)
  try engine.block.setDuration(fadeAnimation, duration: 1.0)
  try engine.block.setEnum(fadeAnimation, property: "animationEasing", value: "EaseInOut")
  // highlight-animationTypes-entranceFade

  let block3 = try createImageBlock(index: 2)

  // highlight-animationTypes-entranceZoom
  let zoomAnimation = try engine.block.createAnimation(.zoom)
  try engine.block.setInAnimation(block3, animation: zoomAnimation)
  try engine.block.setDuration(zoomAnimation, duration: 1.0)
  try engine.block.setBool(zoomAnimation, property: "animation/zoom/fade", value: true)
  // highlight-animationTypes-entranceZoom

  let block4 = try createImageBlock(index: 3)

  // highlight-animationTypes-exitAnimation
  let wipeIn = try engine.block.createAnimation(.wipe)
  try engine.block.setInAnimation(block4, animation: wipeIn)
  try engine.block.setDuration(wipeIn, duration: 1.0)
  try engine.block.setEnum(wipeIn, property: "animation/wipe/direction", value: "Right")

  let fadeOut = try engine.block.createAnimation(.fade)
  try engine.block.setOutAnimation(block4, animation: fadeOut)
  try engine.block.setDuration(fadeOut, duration: 1.0)
  try engine.block.setEnum(fadeOut, property: "animationEasing", value: "EaseIn")
  // highlight-animationTypes-exitAnimation

  let block5 = try createImageBlock(index: 4)

  // highlight-animationTypes-loopAnimation
  let breathingLoop = try engine.block.createAnimation(.breathingLoop)
  try engine.block.setLoopAnimation(block5, animation: breathingLoop)
  try engine.block.setDuration(breathingLoop, duration: 2.0)
  // Intensity: 0 results in a maximum scale of 1.25; 1 results in a maximum scale of 2.5.
  try engine.block.setFloat(breathingLoop, property: "animation/breathing_loop/intensity", value: 0.3)
  // highlight-animationTypes-loopAnimation

  let block6 = try createImageBlock(index: 5)

  // highlight-animationTypes-combinedAnimations
  let spinIn = try engine.block.createAnimation(.spin)
  try engine.block.setInAnimation(block6, animation: spinIn)
  try engine.block.setDuration(spinIn, duration: 1.0)
  try engine.block.setEnum(spinIn, property: "animation/spin/direction", value: "Clockwise")
  try engine.block.setFloat(spinIn, property: "animation/spin/intensity", value: 0.5)

  let blurOut = try engine.block.createAnimation(.blur)
  try engine.block.setOutAnimation(block6, animation: blurOut)
  try engine.block.setDuration(blurOut, duration: 1.0)

  let swayLoop = try engine.block.createAnimation(.swayLoop)
  try engine.block.setLoopAnimation(block6, animation: swayLoop)
  try engine.block.setDuration(swayLoop, duration: 1.5)
  // highlight-animationTypes-combinedAnimations

  // highlight-animationTypes-discoverProperties
  let slideProperties = try engine.block.findAllProperties(slideAnimation)
  let easingOptions = try engine.block.getEnumValues(ofProperty: "animationEasing")
  // highlight-animationTypes-discoverProperties

  // Advance playback so the entrance animations have started by the time the
  // scene is rendered or exported.
  try engine.block.setPlaybackTime(page, time: 1.9)

  _ = slideProperties
  _ = easingOptions
}
