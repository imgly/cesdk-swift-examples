import Foundation
import IMGLYEngine

@MainActor
func modifyingScenes(engine: Engine) async throws {
  // highlight-create-scene
  let scene = try engine.scene.create(sceneLayout: .verticalStack)
  // highlight-create-scene

  // highlight-create-page
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-create-page

  // highlight-create-block
  let block = try engine.block.create(.graphic)
  let shape = try engine.block.createShape(.rect)
  try engine.block.setShape(block, shape: shape)
  let fill = try engine.block.createFill(.color)
  try engine.block.setFill(block, fill: fill)
  try engine.block.setWidth(block, value: 200)
  try engine.block.setHeight(block, value: 200)
  try engine.block.appendChild(to: page, child: block)
  // highlight-create-block

  // highlight-scene-properties
  let designUnit = try engine.scene.getDesignUnit()
  print("Design unit: \(designUnit)")

  try engine.scene.setDesignUnit(.mm)

  let layout = try engine.scene.getLayout()
  print("Layout: \(layout)")
  // highlight-scene-properties

  // highlight-frame-rate-and-markers
  // The preview motion blur and video exports without a frame rate use this rate
  try engine.block.setFloat(scene, property: "scene/frameRate", value: 25)

  // Markers name points or spans on the scene timeline
  try engine.scene.addMarker(name: "intro", time: 0, duration: 2.5)
  try engine.scene.addMarker(name: "beat", time: 4)
  try engine.scene.removeMarker(at: 1)
  print("Markers:", try engine.scene.getMarkers()) // [SceneMarker(name: "intro", time: 0.0, duration: 2.5)]
  // highlight-frame-rate-and-markers

  // highlight-page-navigation
  let pages = try engine.scene.getPages()
  print("Number of pages: \(pages.count)")

  let currentPage = try engine.scene.getCurrentPage()
  print("Current page: \(String(describing: currentPage))")
  // highlight-page-navigation

  // highlight-camera-zoom
  try await engine.scene.zoom(to: page, paddingLeft: 20, paddingTop: 20, paddingRight: 20, paddingBottom: 20)

  let zoomLevel = try engine.scene.getZoom()
  print("Zoom level: \(zoomLevel)")

  try engine.scene.setZoom(1.0)
  // highlight-camera-zoom

  // highlight-save-scene
  let savedScene = try await engine.scene.saveToString()
  print("Scene saved, length: \(savedScene.count)")
  // highlight-save-scene

  // highlight-load-scene
  let loadedScene = try await engine.scene.load(from: savedScene)
  print("Scene loaded: \(loadedScene)")
  // highlight-load-scene

  // highlight-event-subscriptions
  let zoomTask = Task {
    for await _ in engine.scene.onZoomLevelChanged {
      let zoom = try engine.scene.getZoom()
      print("Zoom changed: \(zoom)")
    }
  }

  let activeTask = Task {
    for await _ in engine.scene.onActiveChanged {
      print("Active scene changed")
    }
  }

  zoomTask.cancel()
  activeTask.cancel()
  // highlight-event-subscriptions
}
