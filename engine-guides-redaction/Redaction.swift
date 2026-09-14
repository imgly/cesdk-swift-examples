import IMGLYEngine

// swiftlint:disable function_body_length

@MainActor
func redaction(engine: Engine) async throws {
  let videoURL = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.75.0" +
    "/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
  let segmentDuration = 5.0

  // highlight-redaction-create-scene
  let pageWidth: Float = 1280
  let pageHeight: Float = 720

  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: pageWidth)
  try engine.block.setHeight(page, value: pageHeight)

  try engine.block.setDuration(page, duration: 5 * segmentDuration)
  // highlight-redaction-create-scene

  // highlight-redaction-create-videos
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)

  var videos: [DesignBlockID] = []
  var videoFills: [DesignBlockID] = []
  for index in 0 ..< 5 {
    let video = try engine.block.create(.graphic)
    try engine.block.setShape(video, shape: engine.block.createShape(.rect))

    let videoFill = try engine.block.createFill(.video)
    try engine.block.setString(videoFill, property: "fill/video/fileURI", value: videoURL)
    try engine.block.setFill(video, fill: videoFill)

    try engine.block.appendChild(to: track, child: video)
    try engine.block.setDuration(video, duration: segmentDuration)
    try engine.block.setTimeOffset(video, offset: Double(index) * segmentDuration)

    videos.append(video)
    videoFills.append(videoFill)
  }

  try engine.block.fillParent(track)
  // highlight-redaction-create-videos

  let radialVideo = videos[0]
  let fullBlurVideo = videos[1]
  let pixelVideo = videos[2]
  let timedVideo = videos[4]

  // highlight-redaction-full-block-blur
  if try engine.block.supportsBlur(fullBlurVideo) {
    let uniformBlur = try engine.block.createBlur(.uniform)
    try engine.block.setFloat(uniformBlur, property: "blur/uniform/intensity", value: 0.7)
    try engine.block.setBlur(fullBlurVideo, blurID: uniformBlur)
    try engine.block.setBlurEnabled(fullBlurVideo, enabled: true)
  }
  // highlight-redaction-full-block-blur

  // highlight-redaction-pixelization
  if try engine.block.supportsEffects(pixelVideo) {
    let pixelizeEffect = try engine.block.createEffect(.pixelize)
    try engine.block.setInt(pixelizeEffect, property: "effect/pixelize/horizontalPixelSize", value: 24)
    try engine.block.setInt(pixelizeEffect, property: "effect/pixelize/verticalPixelSize", value: 24)
    try engine.block.appendEffect(pixelVideo, effectID: pixelizeEffect)
    try engine.block.setEffectEnabled(effectID: pixelizeEffect, enabled: true)
  }
  // highlight-redaction-pixelization

  // highlight-redaction-solid-overlay
  let overlay = try engine.block.create(.graphic)
  try engine.block.setShape(overlay, shape: engine.block.createShape(.rect))

  let solidFill = try engine.block.createFill(.color)
  try engine.block.setColor(
    solidFill,
    property: "fill/color/value",
    color: .rgba(r: 0.1, g: 0.1, b: 0.1, a: 1.0),
  )
  try engine.block.setFill(overlay, fill: solidFill)

  try engine.block.setWidth(overlay, value: pageWidth * 0.4)
  try engine.block.setHeight(overlay, value: pageHeight * 0.3)
  try engine.block.setPositionX(overlay, value: pageWidth * 0.55)
  try engine.block.setPositionY(overlay, value: pageHeight * 0.65)
  try engine.block.appendChild(to: page, child: overlay)

  // Show the overlay only during the fourth segment (15–20 seconds).
  try engine.block.setTimeOffset(overlay, offset: 3 * segmentDuration)
  try engine.block.setDuration(overlay, duration: segmentDuration)
  // highlight-redaction-solid-overlay

  // highlight-redaction-time-based-redaction
  let timedBlur = try engine.block.createBlur(.uniform)
  try engine.block.setFloat(timedBlur, property: "blur/uniform/intensity", value: 0.9)
  try engine.block.setBlur(timedVideo, blurID: timedBlur)
  try engine.block.setBlurEnabled(timedVideo, enabled: true)
  // highlight-redaction-time-based-redaction

  // highlight-redaction-radial-blur
  let radialBlur = try engine.block.createBlur(.radial)
  try engine.block.setFloat(radialBlur, property: "blur/radial/blurRadius", value: 50)
  try engine.block.setFloat(radialBlur, property: "blur/radial/radius", value: 25)
  try engine.block.setFloat(radialBlur, property: "blur/radial/gradientRadius", value: 35)
  try engine.block.setFloat(radialBlur, property: "blur/radial/x", value: 0.5)
  try engine.block.setFloat(radialBlur, property: "blur/radial/y", value: 0.45)
  try engine.block.setBlur(radialVideo, blurID: radialBlur)
  try engine.block.setBlurEnabled(radialVideo, enabled: true)
  // highlight-redaction-radial-blur

  // highlight-redaction-save-scene
  let sceneData = try await engine.scene.saveToString()
  // highlight-redaction-save-scene
  _ = sceneData

  // Decode the video frames so the capture below renders the actual content
  // rather than a placeholder.
  for videoFill in videoFills {
    try await engine.block.forceLoadAVResource(videoFill)
  }

  // Hero: seek into the solid-overlay segment so the captured frame reads
  // unambiguously as a privacy redaction.
  try engine.block.setPlaybackTime(page, time: 17.5)
  try await engine.captureGuide(page, label: "hero")
}

// swiftlint:enable function_body_length
