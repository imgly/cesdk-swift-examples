import Foundation
import IMGLYEngine

/// Stand-in for a destination that is not a plain file, for example a multipart
/// upload. A real implementation sends the bytes on and drops them; collecting
/// them would put the whole document back in memory, which is what a streamed
/// export exists to avoid.
private func upload(_ chunk: Data) throws {
  print("Sending \(chunk.count) bytes")
}

@MainActor
func exportToPdf(engine: Engine) async throws {
  // Demo scaffolding: build a small scene with renderable content so every
  // highlighted snippet has something to export. In your app you would start
  // from a scene already loaded into the editor instead.
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  let star = try engine.block.create(.graphic)
  try engine.block.setShape(star, shape: engine.block.createShape(.star))
  try engine.block.setPositionX(star, value: 350)
  try engine.block.setPositionY(star, value: 250)
  try engine.block.setWidth(star, value: 100)
  try engine.block.setHeight(star, value: 100)
  let starFill = try engine.block.createFill(.color)
  try engine.block.setColor(starFill, property: "fill/color/value", color: .rgba(r: 0, g: 0, b: 1, a: 1))
  try engine.block.setFill(star, fill: starFill)
  try engine.block.appendChild(to: page, child: star)

  let exportsDirectory = FileManager.default.temporaryDirectory

  // highlight-exportToPdf-export
  let pdfBlob = try await engine.block.export(scene, mimeType: .pdf)
  try pdfBlob.write(to: exportsDirectory.appendingPathComponent("design.pdf"))
  // highlight-exportToPdf-export

  // highlight-exportToPdf-progress
  // Report per-page progress as the PDF is written. The closure runs once per
  // page; only PDF exports invoke it.
  let progressBlob = try await engine.block.export(
    scene,
    mimeType: .pdf,
    onProgress: { exportedPages, totalPages in
      print("Exported \(exportedPages) of \(totalPages) pages")
    },
  )
  try progressBlob.write(to: exportsDirectory.appendingPathComponent("design-with-progress.pdf"))
  // highlight-exportToPdf-progress

  // highlight-exportToPdf-stream
  // Write the document straight into a file as it is encoded. Nothing buffers
  // the finished PDF, so peak memory stays bounded by a single page rather than
  // growing with the page count.
  try await engine.block.export(
    scene,
    to: exportsDirectory.appendingPathComponent("design-streamed.pdf"),
    mimeType: .pdf,
    onProgress: { exportedPages, totalPages in
      print("Streamed \(exportedPages) of \(totalPages) pages")
    },
  )
  // highlight-exportToPdf-stream

  // highlight-exportToPdf-chunks
  // Hand the chunks to a destination that is not a plain file. The closure runs
  // while the encoder does, so a slow destination throttles the encoder instead
  // of letting chunks queue up.
  try await engine.block.export(scene) { chunk in
    try upload(chunk)
  }
  // highlight-exportToPdf-chunks

  // highlight-exportToPdf-chunkSize
  // Choose how large a chunk may get. This is the memory held for one chunk, so
  // lower it for a memory-tight destination and raise it when the per-chunk work
  // is expensive, for example one request per chunk.
  try await engine.block.export(scene, options: ExportOptions(pdfChunkSize: 64 * 1024)) { chunk in
    try upload(chunk)
  }
  // highlight-exportToPdf-chunkSize

  // highlight-exportToPdf-cancel
  // Cancelling the task that runs the export stops the export itself. Keep the
  // task in your view model and cancel it from your Cancel button.
  let exportTask = Task {
    try await engine.block.export(scene, mimeType: .pdf)
  }
  exportTask.cancel()
  do {
    _ = try await exportTask.value
  } catch {
    // A cancelled export produces no data.
    print("Export cancelled: \(error)")
  }
  // highlight-exportToPdf-cancel

  // highlight-exportToPdf-highCompatibility
  let highCompatibilityOptions = ExportOptions(exportPdfWithHighCompatibility: true)
  let highCompatibilityBlob = try await engine.block.export(
    page,
    mimeType: .pdf,
    options: highCompatibilityOptions,
  )
  try highCompatibilityBlob.write(to: exportsDirectory.appendingPathComponent("design-high-compatibility.pdf"))
  // highlight-exportToPdf-highCompatibility

  // highlight-exportToPdf-spotColor
  engine.editor.setSpotColor(name: "RDG_WHITE", r: 0.8, g: 0.8, b: 0.8)
  // highlight-exportToPdf-spotColor

  // highlight-exportToPdf-underlayer
  let underlayerOptions = ExportOptions(
    exportPdfWithHighCompatibility: true,
    exportPdfWithUnderlayer: true,
    underlayerSpotColorName: "RDG_WHITE",
    underlayerOffset: -2.0,
  )
  let underlayerBlob = try await engine.block.export(page, mimeType: .pdf, options: underlayerOptions)
  try underlayerBlob.write(to: exportsDirectory.appendingPathComponent("design-with-underlayer.pdf"))
  // highlight-exportToPdf-underlayer

  // highlight-exportToPdf-targetSize
  let a4Options = ExportOptions(targetWidth: 2480, targetHeight: 3508)
  let a4Blob = try await engine.block.export(page, mimeType: .pdf, options: a4Options)
  try a4Blob.write(to: exportsDirectory.appendingPathComponent("design-a4.pdf"))
  // highlight-exportToPdf-targetSize
}
