import Foundation
import IMGLYEngine

@MainActor
func limitations(engine: Engine) async throws {
  // highlight-limitations-queryMaxExportSize
  let maxExportSize = try engine.editor.getMaxExportSize()
  // highlight-limitations-queryMaxExportSize

  // highlight-limitations-queryMemoryUsage
  let usedMemory = try engine.editor.getUsedMemory()
  let usedMemoryMB = Double(usedMemory) / (1024 * 1024)
  // highlight-limitations-queryMemoryUsage

  // highlight-limitations-queryAvailableMemory
  let availableMemory = try? engine.editor.getAvailableMemory()
  let availableMemoryMB = availableMemory.map { Double($0) / (1024 * 1024) }
  // highlight-limitations-queryAvailableMemory

  // highlight-limitations-calculateMemoryPercentage
  let memoryUtilization: Double? = availableMemory.map { available in
    let total = Double(usedMemory + available)
    return total > 0 ? (Double(usedMemory) / total) * 100 : 0
  }
  // highlight-limitations-calculateMemoryPercentage

  // highlight-limitations-checkExportFeasibility
  let desiredWidth = 3840
  let desiredHeight = 2160
  let limitKnown = maxExportSize < Int(Int32.max)
  let canExport4K = limitKnown
    && desiredWidth <= maxExportSize
    && desiredHeight <= maxExportSize
  // highlight-limitations-checkExportFeasibility

  _ = usedMemoryMB
  _ = availableMemoryMB
  _ = memoryUtilization
  _ = limitKnown
  _ = canExport4K
}
