import Foundation
import IMGLYEngine

@MainActor
func cancelOperations(engine: Engine) async throws {
  let baseURL = try engine.guidesBaseURL

  // Demo scaffolding: a page with an image block gives the exports below some content.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.setDuration(page, duration: 5)
  try engine.block.appendChild(to: scene, child: page)

  let imageBlock = try engine.block.create(.graphic)
  try engine.block.setShape(imageBlock, shape: engine.block.createShape(.rect))
  let imageFill = try engine.block.createFill(.image)
  try engine.block.setURL(
    imageFill,
    property: "fill/image/imageFileURI",
    value: baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg"),
  )
  try engine.block.setFill(imageBlock, fill: imageFill)
  try engine.block.setWidth(imageBlock, value: 800)
  try engine.block.setHeight(imageBlock, value: 600)
  try engine.block.appendChild(to: page, child: imageBlock)

  // highlight-cancelOperations-cancelExport
  let exportTask = Task {
    try await engine.block.export(page, mimeType: .png)
  }
  exportTask.cancel()

  do {
    let blob = try await exportTask.value
    print("The export ended before the cancel with \(blob.count) bytes")
  } catch is CancellationError {
    print("The export stopped")
  }
  // highlight-cancelOperations-cancelExport

  // highlight-cancelOperations-exportAgain
  let blob = try await engine.block.export(page, mimeType: .png)
  print("The next export made a PNG file of \(blob.count) bytes")
  // highlight-cancelOperations-exportAgain

  if let video = try await exportVideoUnlessSlow(engine: engine, page: page) {
    print("The video file has \(video.count) bytes")
  } else {
    print("The video export was too slow and stopped")
  }

  let sceneURL = baseURL.appendingPathComponent("ly.img.templates/templates/cesdk_business_card_1.scene")
  // highlight-cancelOperations-deadline
  let loadedInTime = try await withThrowingTaskGroup(of: Bool.self) { group in
    group.addTask {
      try await engine.scene.load(from: sceneURL)
      return true
    }
    group.addTask {
      try await Task.sleep(nanoseconds: 10 * NSEC_PER_SEC)
      return false
    }
    let first = try await group.next() ?? false
    group.cancelAll()
    return first
  }
  print(loadedInTime ? "The scene loaded in time" : "The scene did not load within 10 seconds")
  // highlight-cancelOperations-deadline
}

// highlight-cancelOperations-videoProgress
@MainActor
private func exportVideoUnlessSlow(engine: Engine, page: DesignBlockID) async throws -> Blob? {
  let startedAt = Date()
  for try await event in try await engine.block.exportVideo(page, mimeType: .mp4) {
    switch event {
    case let .progress(renderedFrames, _, totalFrames):
      if Date().timeIntervalSince(startedAt) > 60, renderedFrames < totalFrames / 2 {
        return nil
      }
    case let .finished(video: video):
      return video
    }
  }
  return nil
}

// highlight-cancelOperations-videoProgress
