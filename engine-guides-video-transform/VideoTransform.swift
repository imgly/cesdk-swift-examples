import Foundation
import IMGLYEngine

@MainActor
func transformVideo(engine: Engine) throws {
  // Resolve the sample video against the engine's base URL.
  let baseURL = try engine.guidesBaseURL
  let sampleVideoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 8)

  // Four video blocks, one per transformation demonstrated below.
  let positionedVideo = try engine.block.create(.graphic)
  let positionedVideoFill = try engine.block.createFill(.video)
  try engine.block.setName(positionedVideo, name: "Positioned video")
  try engine.block.setShape(positionedVideo, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(positionedVideo, value: 80)
  try engine.block.setPositionY(positionedVideo, value: 80)
  try engine.block.setWidth(positionedVideo, value: 300)
  try engine.block.setHeight(positionedVideo, value: 170)
  try engine.block.setURL(positionedVideoFill, property: "fill/video/fileURI", value: sampleVideoURL)
  try engine.block.setFill(positionedVideo, fill: positionedVideoFill)
  try engine.block.setContentFillMode(positionedVideo, mode: .cover)
  try engine.block.setDuration(positionedVideo, duration: 8)
  try engine.block.appendChild(to: page, child: positionedVideo)

  let rotatedVideo = try engine.block.create(.graphic)
  let rotatedVideoFill = try engine.block.createFill(.video)
  try engine.block.setName(rotatedVideo, name: "Rotated video")
  try engine.block.setShape(rotatedVideo, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(rotatedVideo, value: 460)
  try engine.block.setPositionY(rotatedVideo, value: 80)
  try engine.block.setWidth(rotatedVideo, value: 300)
  try engine.block.setHeight(rotatedVideo, value: 170)
  try engine.block.setURL(rotatedVideoFill, property: "fill/video/fileURI", value: sampleVideoURL)
  try engine.block.setFill(rotatedVideo, fill: rotatedVideoFill)
  try engine.block.setContentFillMode(rotatedVideo, mode: .cover)
  try engine.block.setDuration(rotatedVideo, duration: 8)
  try engine.block.appendChild(to: page, child: rotatedVideo)

  let croppedVideo = try engine.block.create(.graphic)
  let croppedVideoFill = try engine.block.createFill(.video)
  try engine.block.setName(croppedVideo, name: "Cropped video")
  try engine.block.setShape(croppedVideo, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(croppedVideo, value: 80)
  try engine.block.setPositionY(croppedVideo, value: 360)
  try engine.block.setWidth(croppedVideo, value: 300)
  try engine.block.setHeight(croppedVideo, value: 170)
  try engine.block.setURL(croppedVideoFill, property: "fill/video/fileURI", value: sampleVideoURL)
  try engine.block.setFill(croppedVideo, fill: croppedVideoFill)
  try engine.block.setContentFillMode(croppedVideo, mode: .cover)
  try engine.block.setDuration(croppedVideo, duration: 8)
  try engine.block.appendChild(to: page, child: croppedVideo)

  let lockedVideo = try engine.block.create(.graphic)
  let lockedVideoFill = try engine.block.createFill(.video)
  try engine.block.setName(lockedVideo, name: "Locked video")
  try engine.block.setShape(lockedVideo, shape: engine.block.createShape(.rect))
  try engine.block.setPositionX(lockedVideo, value: 460)
  try engine.block.setPositionY(lockedVideo, value: 360)
  try engine.block.setWidth(lockedVideo, value: 300)
  try engine.block.setHeight(lockedVideo, value: 170)
  try engine.block.setURL(lockedVideoFill, property: "fill/video/fileURI", value: sampleVideoURL)
  try engine.block.setFill(lockedVideo, fill: lockedVideoFill)
  try engine.block.setContentFillMode(lockedVideo, mode: .cover)
  try engine.block.setDuration(lockedVideo, duration: 8)
  try engine.block.appendChild(to: page, child: lockedVideo)

  // highlight-videoTransform-blockTransforms
  try engine.block.setPositionXMode(positionedVideo, mode: .absolute)
  try engine.block.setPositionYMode(positionedVideo, mode: .absolute)
  try engine.block.setPositionX(positionedVideo, value: 120)
  try engine.block.setPositionY(positionedVideo, value: 104)

  try engine.block.setFlipHorizontal(rotatedVideo, flip: true)
  try engine.block.scale(rotatedVideo, to: 1.15, anchorX: 0.5, anchorY: 0.5)
  try engine.block.setRotation(rotatedVideo, radians: .pi / 8)

  try engine.block.setWidth(lockedVideo, value: 280, maintainCrop: true)
  try engine.block.setHeight(lockedVideo, value: 158, maintainCrop: true)
  // highlight-videoTransform-blockTransforms

  // highlight-videoTransform-contentTransforms
  if try engine.block.supportsCrop(croppedVideo) {
    try engine.block.setContentFillMode(croppedVideo, mode: .crop)
    try engine.block.setCropScaleRatio(croppedVideo, scaleRatio: 1.35)
    // Crop translations are relative to the block frame dimensions.
    try engine.block.setCropTranslationX(croppedVideo, translationX: -0.12)
    try engine.block.setCropTranslationY(croppedVideo, translationY: 0.08)
    try engine.block.setCropRotation(croppedVideo, rotation: .pi / 18)
    try engine.block.adjustCropToFillFrame(croppedVideo, minScaleRatio: 1.0)
  }
  // highlight-videoTransform-contentTransforms

  // highlight-videoTransform-transformControls
  try engine.editor.setSettingBool("controlGizmo/showMoveHandles", value: true)
  try engine.editor.setSettingBool("controlGizmo/showResizeHandles", value: true)
  try engine.editor.setSettingBool("controlGizmo/showScaleHandles", value: true)
  try engine.editor.setSettingBool("controlGizmo/showRotateHandles", value: true)
  try engine.editor.setSettingBool("controlGizmo/showCropHandles", value: true)
  try engine.editor.setSettingFloat("controlGizmo/blockScaleDownLimit", value: 12)
  try engine.editor.setSettingEnum("touch/rotateAction", value: "Rotate")
  try engine.editor.setSettingEnum("touch/pinchAction", value: "Scale")
  // highlight-videoTransform-transformControls

  // highlight-videoTransform-groupTransforms
  if try engine.block.isGroupable([positionedVideo, croppedVideo]) {
    let group = try engine.block.group([positionedVideo, croppedVideo])
    try engine.block.setPositionX(group, value: 180)
    try engine.block.setRotation(group, radians: .pi / 16)
  }
  // highlight-videoTransform-groupTransforms

  // highlight-videoTransform-animatedTransforms
  if try engine.block.supportsAnimation(rotatedVideo) {
    let loopAnimation = try engine.block.createAnimation(.spinLoop)
    try engine.block.setLoopAnimation(rotatedVideo, animation: loopAnimation)
    try engine.block.setDuration(loopAnimation, duration: 2)
    try engine.block.setTimeOffset(rotatedVideo, offset: 1)
  }
  // highlight-videoTransform-animatedTransforms

  // highlight-videoTransform-lockTransforms
  let blockFrameScopes = ["layer/move", "layer/rotate", "layer/resize", "layer/flip"]
  for scope in blockFrameScopes + ["layer/crop"] {
    try engine.editor.setGlobalScope(key: scope, value: .defer)
  }
  for scope in blockFrameScopes {
    try engine.block.setScopeEnabled(lockedVideo, key: scope, enabled: false)
  }
  try engine.block.setScopeEnabled(lockedVideo, key: "layer/crop", enabled: false)
  try engine.block.setTransformLocked(lockedVideo, locked: true)

  let transformsLocked = try engine.block.isTransformLocked(lockedVideo)
  let moveScopeEnabled = try engine.block.isScopeEnabled(lockedVideo, key: "layer/move")
  let moveAllowed = try engine.block.isAllowedByScope(lockedVideo, key: "layer/move")
  print("transformsLocked=\(transformsLocked) moveScopeEnabled=\(moveScopeEnabled) moveAllowed=\(moveAllowed)")
  // highlight-videoTransform-lockTransforms
}
