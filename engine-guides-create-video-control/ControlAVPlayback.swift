import Foundation
import IMGLYEngine

@MainActor
func controlAVPlayback(engine: Engine) async throws {
  // Demo scaffolding: a video scene with a single video block on a track.
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)

  let videoBlock = try engine.block.create(.graphic)
  try engine.block.setShape(videoBlock, shape: engine.block.createShape(.rect))
  let videoFill = try engine.block.createFill(.video)
  let videoURL = "https://cdn.img.ly/packages/imgly/cesdk-swift/1.75.0" +
    "/assets/ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4"
  try engine.block.setString(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(videoBlock, fill: videoFill)

  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.appendChild(to: track, child: videoBlock)
  try engine.block.fillParent(track)
  try engine.block.setDuration(videoBlock, duration: 10)

  // highlight-controlAV-forceLoad
  try await engine.block.forceLoadAVResource(videoFill)
  // highlight-controlAV-forceLoad

  // highlight-controlAV-metadata
  let videoWidth = try engine.block.getVideoWidth(videoFill)
  let videoHeight = try engine.block.getVideoHeight(videoFill)
  let totalDuration = try engine.block.getAVResourceTotalDuration(videoFill)
  // highlight-controlAV-metadata
  _ = (videoWidth, videoHeight, totalDuration)

  // highlight-controlAV-playbackControl
  if try engine.block.supportsPlaybackControl(page) {
    let isPlaying = try engine.block.isPlaying(page)
    try engine.block.setPlaying(page, enabled: !isPlaying)
  }
  // highlight-controlAV-playbackControl

  // highlight-controlAV-seeking
  var currentTime: Double = 0
  if try engine.block.supportsPlaybackTime(page) {
    try engine.block.setPlaybackTime(page, time: 3.0)
    currentTime = try engine.block.getPlaybackTime(page)
  }
  // highlight-controlAV-seeking
  _ = currentTime

  // highlight-controlAV-visibility
  let isVisible = try engine.block.isVisibleAtCurrentPlaybackTime(videoBlock)
  // highlight-controlAV-visibility
  _ = isVisible

  // highlight-controlAV-solo
  try engine.block.setSoloPlaybackEnabled(videoFill, enabled: true)
  let soloEnabled = try engine.block.isSoloPlaybackEnabled(videoFill)
  try engine.block.setSoloPlaybackEnabled(videoFill, enabled: false)
  // highlight-controlAV-solo
  _ = soloEnabled
}
