import Foundation
import IMGLYEngine

@MainActor
func setZoomLevel(engine: Engine) async throws {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let graphic = try engine.block.create(.graphic)
  try engine.block.setShape(graphic, shape: try engine.block.createShape(.rect))
  try engine.block.setFill(graphic, fill: try engine.block.createFill(.color))
  try engine.block.setWidth(graphic, value: 300)
  try engine.block.setHeight(graphic, value: 300)
  try engine.block.appendChild(to: page, child: graphic)

  // highlight-setZoomLevel-getSet
  try engine.scene.setZoom(1.0)

  let currentZoom = try engine.scene.getZoom()
  try engine.scene.setZoom(0.5 * currentZoom)
  // highlight-setZoomLevel-getSet

  // highlight-setZoomLevel-zoomToBlock
  try await engine.scene.zoom(
    to: page,
    paddingLeft: 20,
    paddingTop: 20,
    paddingRight: 20,
    paddingBottom: 20,
  )

  try engine.scene.immediateZoom(
    to: page,
    paddingLeft: 20,
    paddingTop: 20,
    paddingRight: 20,
    paddingBottom: 20,
    forceUpdate: true,
  )
  // highlight-setZoomLevel-zoomToBlock

  // highlight-setZoomLevel-autoFit
  try engine.scene.enableZoomAutoFit(
    page,
    axis: .both,
    paddingLeft: 20,
    paddingTop: 20,
    paddingRight: 20,
    paddingBottom: 20,
  )
  // highlight-setZoomLevel-autoFit

  // highlight-setZoomLevel-disableAutoFit
  let autoFitEnabled = try engine.scene.isZoomAutoFitEnabled(page)
  print("Auto-fit enabled: \(autoFitEnabled)")

  try engine.scene.disableZoomAutoFit(page)
  // highlight-setZoomLevel-disableAutoFit

  // highlight-setZoomLevel-zoomClamping
  try engine.scene.unstable_enableCameraZoomClamping(
    [page],
    minZoomLimit: 0.125,
    maxZoomLimit: 8.0,
  )

  let zoomClampingEnabled = try engine.scene.unstable_isCameraZoomClampingEnabled(scene)
  print("Zoom clamping enabled: \(zoomClampingEnabled)")

  try engine.scene.unstable_disableCameraZoomClamping()
  // highlight-setZoomLevel-zoomClamping

  // highlight-setZoomLevel-positionClamping
  try engine.scene.unstable_enableCameraPositionClamping(
    [scene],
    paddingLeft: 10,
    paddingTop: 10,
    paddingRight: 10,
    paddingBottom: 10,
  )

  let positionClampingEnabled = try engine.scene.unstable_isCameraPositionClampingEnabled(scene)
  print("Position clamping enabled: \(positionClampingEnabled)")

  try engine.scene.unstable_disableCameraPositionClamping()
  // highlight-setZoomLevel-positionClamping

  // highlight-setZoomLevel-subscribe
  let zoomTask = Task {
    for await _ in engine.scene.onZoomLevelChanged {
      let zoom = try engine.scene.getZoom()
      print("Zoom level changed: \(zoom)")
    }
  }

  try engine.scene.setZoom(2.0)
  zoomTask.cancel()
  // highlight-setZoomLevel-subscribe
}
