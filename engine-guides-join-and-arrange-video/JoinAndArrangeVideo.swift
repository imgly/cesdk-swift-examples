import Foundation
import IMGLYEngine

@MainActor
func joinAndArrangeVideo(engine: Engine) async throws {
  let videoURL = URL(
    string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.0-rc.1/assets/ly.img.video/videos/" +
      "pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )!

  // highlight-joinAndArrange-create-scene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)
  try engine.block.setDuration(page, duration: 15)
  // highlight-joinAndArrange-create-scene

  // highlight-joinAndArrange-create-clips
  let clipA = try await makeVideoClip(engine: engine, name: "Clip A", videoURL: videoURL, width: 1920, height: 1080)
  let clipB = try await makeVideoClip(engine: engine, name: "Clip B", videoURL: videoURL, width: 1920, height: 1080)
  let clipC = try await makeVideoClip(engine: engine, name: "Clip C", videoURL: videoURL, width: 1920, height: 1080)
  // highlight-joinAndArrange-create-clips

  // highlight-joinAndArrange-create-track
  let track = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: track)
  try engine.block.setBool(track, property: "track/automaticallyManageBlockOffsets", value: false)
  // highlight-joinAndArrange-create-track

  // highlight-joinAndArrange-add-clips-to-track
  try engine.block.appendChild(to: track, child: clipA)
  try engine.block.appendChild(to: track, child: clipB)
  try engine.block.appendChild(to: track, child: clipC)

  try engine.block.fillParent(track)
  // highlight-joinAndArrange-add-clips-to-track
  let initialOrder = try engine.block.getChildren(track)
  assert(initialOrder == [clipA, clipB, clipC])

  // highlight-joinAndArrange-set-clip-durations
  try engine.block.setDuration(clipA, duration: 5)
  try engine.block.setDuration(clipB, duration: 5)
  try engine.block.setDuration(clipC, duration: 5)
  try engine.block.setDuration(track, duration: 15)
  // highlight-joinAndArrange-set-clip-durations

  // highlight-joinAndArrange-time-offsets
  try engine.block.setTimeOffset(clipA, offset: 0)
  try engine.block.setTimeOffset(clipB, offset: 5)
  try engine.block.setTimeOffset(clipC, offset: 10)
  // highlight-joinAndArrange-time-offsets

  // highlight-joinAndArrange-reorder-clips
  try engine.block.insertChild(into: track, child: clipC, at: 0)
  try engine.block.setTimeOffset(clipC, offset: 0)
  try engine.block.setTimeOffset(clipA, offset: 5)
  try engine.block.setTimeOffset(clipB, offset: 10)
  // highlight-joinAndArrange-reorder-clips

  // highlight-joinAndArrange-query-track-children
  let children = try engine.block.getChildren(track)
  for (index, clip) in children.enumerated() {
    let name = try engine.block.getName(clip)
    let offset = try engine.block.getTimeOffset(clip)
    let duration = try engine.block.getDuration(clip)
    print("Position \(index): \(name) at \(offset)s for \(duration)s")
  }
  // highlight-joinAndArrange-query-track-children
  let finalNames = try children.map { try engine.block.getName($0) }
  let finalOffsets = try children.map { try engine.block.getTimeOffset($0) }
  assert(finalNames == ["Clip C", "Clip A", "Clip B"])
  assert(finalOffsets == [0, 5, 10])

  // highlight-joinAndArrange-multi-track
  let overlayTrack = try engine.block.create(.track)
  try engine.block.appendChild(to: page, child: overlayTrack)
  try engine.block.setTimeOffset(overlayTrack, offset: 2)

  let overlayClip = try await makeVideoClip(
    engine: engine,
    name: "Overlay Clip",
    videoURL: videoURL,
    width: 1920 / 4,
    height: 1080 / 4,
  )
  try engine.block.setDuration(overlayClip, duration: 5)
  try engine.block.appendChild(to: overlayTrack, child: overlayClip)
  try engine.block.setPositionX(overlayClip, value: 1920 - 1920 / 4 - 40)
  try engine.block.setPositionY(overlayClip, value: 1080 - 1080 / 4 - 40)
  // highlight-joinAndArrange-multi-track
}

// highlight-joinAndArrange-clip-helper
@MainActor
private func makeVideoClip(
  engine: Engine,
  name: String,
  videoURL: URL,
  width: Float,
  height: Float,
) async throws -> DesignBlockID {
  let clip = try engine.block.create(.graphic)
  try engine.block.setName(clip, name: name)
  try engine.block.setShape(clip, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(clip, value: width)
  try engine.block.setHeight(clip, value: height)

  let videoFill = try engine.block.createFill(.video)
  try engine.block.setString(videoFill, property: "fill/video/fileURI", value: videoURL.absoluteString)
  try engine.block.setFill(clip, fill: videoFill)
  try engine.block.setContentFillMode(clip, mode: .cover)
  try await engine.block.forceLoadAVResource(videoFill)

  return clip
}

// highlight-joinAndArrange-clip-helper
