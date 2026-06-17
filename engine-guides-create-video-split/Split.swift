import Foundation
import IMGLYEngine

@MainActor
func split(engine: Engine) async throws {
  // highlight-setupScene
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 60)
  // highlight-setupScene

  let baseURL = try engine.guidesBaseURL

  // highlight-makeVideoBlock
  let videoURL = baseURL.appendingPathComponent(
    "ly.img.video/videos/pexels-drone-footage-of-a-surfer-barrelling-a-wave-12715991.mp4",
  )

  func makeVideoBlock() async throws -> DesignBlockID {
    let block = try engine.block.create(.graphic)
    try engine.block.setShape(block, shape: engine.block.createShape(.rect))
    let fill = try engine.block.createFill(.video)
    try engine.block.setURL(fill, property: "fill/video/fileURI", value: videoURL)
    try engine.block.setFill(block, fill: fill)
    try engine.block.appendChild(to: page, child: block)
    try await engine.block.forceLoadAVResource(fill)
    try engine.block.setDuration(block, duration: 10)
    return block
  }
  // highlight-makeVideoBlock

  // highlight-basic-split
  let basicVideo = try await makeVideoBlock()
  let newBlock = try engine.block.split(basicVideo, atTime: 5.0)
  // highlight-basic-split
  _ = newBlock

  // highlight-split-options
  let optionsVideo = try await makeVideoBlock()
  let optionsNewBlock = try engine.block.split(
    optionsVideo,
    atTime: 4.0,
    options: SplitOptions(
      attachToParent: true,
      createParentTrackIfNeeded: false,
      selectNewBlock: false,
    ),
  )
  // highlight-split-options
  _ = optionsNewBlock

  // highlight-split-at-playhead
  let playheadVideo = try await makeVideoBlock()
  // In a real app the user moves the playhead via the timeline UI;
  // here we position it programmatically so the demo has a known split point.
  try engine.block.setPlaybackTime(page, time: 3.0)
  let playheadTime = try engine.block.getPlaybackTime(page)
  let clipStartTime = try engine.block.getTimeOffset(playheadVideo)
  let splitTime = playheadTime - clipStartTime
  let playheadNewBlock = try engine.block.split(playheadVideo, atTime: splitTime)
  // highlight-split-at-playhead
  _ = playheadNewBlock

  // highlight-split-results
  let resultsVideo = try await makeVideoBlock()
  let resultsFill = try engine.block.getFill(resultsVideo)
  let originalTrimOffset = try engine.block.getTrimOffset(resultsFill)
  let originalTrimLength = try engine.block.getTrimLength(resultsFill)
  let resultsNewBlock = try engine.block.split(resultsVideo, atTime: 6.0)
  let resultsNewFill = try engine.block.getFill(resultsNewBlock)
  let originalAfterOffset = try engine.block.getTrimOffset(resultsFill)
  let originalAfterLength = try engine.block.getTrimLength(resultsFill)
  let newBlockTrimOffset = try engine.block.getTrimOffset(resultsNewFill)
  let newBlockTrimLength = try engine.block.getTrimLength(resultsNewFill)
  // highlight-split-results
  _ = (originalTrimOffset, originalTrimLength, originalAfterOffset, originalAfterLength)
  _ = (newBlockTrimOffset, newBlockTrimLength)

  // highlight-split-and-delete
  let deleteVideo = try await makeVideoBlock()
  // Split at the start of the section to remove.
  let middleBlock = try engine.block.split(deleteVideo, atTime: 2.0)
  // Split again 3 seconds into middleBlock to mark the end of the section.
  let endBlock = try engine.block.split(middleBlock, atTime: 3.0)
  try engine.block.destroy(middleBlock)
  // highlight-split-and-delete
  _ = endBlock

  // highlight-validate-split-time
  let validateVideo = try await makeVideoBlock()
  try engine.block.setDuration(validateVideo, duration: 8.0)
  let blockDuration = try engine.block.getDuration(validateVideo)
  let desiredSplitTime = 4.0
  var validatedNewBlock: DesignBlockID?
  if try engine.block.supportsTrim(validateVideo),
     desiredSplitTime > 0,
     desiredSplitTime < blockDuration {
    validatedNewBlock = try engine.block.split(validateVideo, atTime: desiredSplitTime)
  }
  // highlight-validate-split-time
  _ = validatedNewBlock
}
