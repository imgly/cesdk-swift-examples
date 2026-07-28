import Foundation
import IMGLYEngine

@MainActor
func applyTransitions(engine: Engine) async throws {
  // highlight-applyTransitions-createScene
  let scene = try engine.scene.createVideo()

  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 16)

  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  // highlight-applyTransitions-createScene

  let baseURL = try engine.guidesBaseURL
  let videoURLs = [
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
    "ly.img.video/videos/pexels-tony-schnagl-5528015.mp4",
    "ly.img.video/videos/pexels-taryn-elliott-8713114.mp4",
    "ly.img.video/videos/pexels-taryn-elliott-7108801.mp4",
  ].map { baseURL.appendingPathComponent($0) }

  // highlight-applyTransitions-createClips
  var clips = [DesignBlockID]()
  for (index, videoURL) in videoURLs.enumerated() {
    let clip = try await makeTransitionClip(engine: engine, videoURL: videoURL, width: 1280, height: 720)
    try engine.block.appendChild(to: track, child: clip)
    try engine.block.setDuration(clip, duration: 4)
    try engine.block.setTimeOffset(clip, offset: Double(index) * 4)
    clips.append(clip)
  }
  try engine.block.fillParent(track)

  let clipA = clips[0]
  let clipB = clips[1]
  let clipC = clips[2]
  // highlight-applyTransitions-createClips

  try engine.block.setPlaybackTime(page, time: 3.5)
  try await engine.captureGuide(page, label: "before-transition")

  // highlight-applyTransitions-checkSupport
  let clipsSupportTransitions = try engine.block.supportsTransition(clipA)
    && engine.block.supportsTransition(clipB)
  print("Clips support transitions: \(clipsSupportTransitions)")
  // highlight-applyTransitions-checkSupport

  // highlight-applyTransitions-createTransition
  let crossFade = try engine.block.createTransition(.crossFade)
  try engine.block.setDuration(crossFade, duration: 1)
  // highlight-applyTransitions-createTransition

  // highlight-applyTransitions-setTransition
  try engine.block.setTransition(clipA, transition: crossFade)
  // highlight-applyTransitions-setTransition

  // highlight-applyTransitions-timelineReflow
  let incomingClipOffset = try engine.block.getTimeOffset(clipB)
  print("Clip B now starts at \(incomingClipOffset)s (was 4)")
  // highlight-applyTransitions-timelineReflow

  // highlight-applyTransitions-configureProperties
  let push = try engine.block.createTransition(.push)
  try engine.block.setDuration(push, duration: 1)
  try engine.block.setTransition(clipB, transition: push)

  let pushProperties = try engine.block.findAllProperties(push)
  print("Push properties: \(pushProperties)")

  try engine.block.setEnum(push, property: "transition/push/direction", value: "Left")
  // highlight-applyTransitions-configureProperties

  // highlight-applyTransitions-morph
  try engine.block.setBool(push, property: "transition/push/morph", value: true)
  // highlight-applyTransitions-morph

  try engine.block.setPlaybackTime(page, time: 6.5)
  try await engine.captureGuide(page, label: "after-push")

  // highlight-applyTransitions-getTransition
  let assigned = try engine.block.getTransition(clipA)
  if engine.block.isValid(assigned) {
    print("Clip A transitions with: \(try engine.block.getType(assigned))")
  }
  // highlight-applyTransitions-getTransition

  // highlight-applyTransitions-removeTransition
  let fadeToBlack = try engine.block.createTransition(.fadeToBlack)
  try engine.block.setDuration(fadeToBlack, duration: 1)
  try engine.block.setTransition(clipC, transition: fadeToBlack)

  try engine.block.removeTransition(clipC)
  print("Detached transition is still valid: \(engine.block.isValid(fadeToBlack))")
  try engine.block.destroy(fadeToBlack)

  let colorWipe = try engine.block.createTransition(.colorWipe)
  try engine.block.setDuration(colorWipe, duration: 1)
  try engine.block.setTransition(clipC, transition: colorWipe)
  try engine.block.setEnum(colorWipe, property: "transition/color-wipe/direction", value: "Up")
  try engine.block.setColor(
    colorWipe,
    property: "transition/color-wipe/color",
    color: .rgba(r: 1, g: 1, b: 1, a: 1),
  )
  // highlight-applyTransitions-removeTransition

  // Just before the midpoint of the [9, 10] window: the wipe color covers the frame completely at
  // the midpoint, so park slightly earlier to catch the band partway across.
  try engine.block.setPlaybackTime(page, time: 9.45)
  try await engine.captureGuide(page, label: "after-color-wipe")

  // Fit the page to the reflowed sequence, then park the playhead inside the first overlap window
  // so the cross-fade blend is the frame the hero shows.
  if let lastClip = clips.last {
    let end = try engine.block.getTimeOffset(lastClip) + engine.block.getDuration(lastClip)
    try engine.block.setDuration(page, duration: end)
  }
  try engine.block.setPlaybackTime(page, time: 3.5)
  try await engine.captureGuide(page, label: "hero")
}

// highlight-applyTransitions-clipHelper
@MainActor
private func makeTransitionClip(
  engine: Engine,
  videoURL: URL,
  width: Float,
  height: Float,
) async throws -> DesignBlockID {
  let clip = try engine.block.create(.graphic)
  try engine.block.setShape(clip, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(clip, value: width)
  try engine.block.setHeight(clip, value: height)

  let videoFill = try engine.block.createFill(.video)
  try engine.block.setURL(videoFill, property: "fill/video/fileURI", value: videoURL)
  try engine.block.setFill(clip, fill: videoFill)
  try engine.block.setContentFillMode(clip, mode: .cover)
  try await engine.block.forceLoadAVResource(videoFill)

  return clip
}

// highlight-applyTransitions-clipHelper
