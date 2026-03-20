import IMGLYEngine

@MainActor
func undoAndHistory(engine: Engine) async throws {
  // highlight-undoAndHistory-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-undoAndHistory-setup

  // highlight-undoAndHistory-subscribe
  let historyTask = Task {
    for await _ in engine.editor.onHistoryUpdated {
      let canUndo = try engine.editor.canUndo()
      let canRedo = try engine.editor.canRedo()
      print("History updated — canUndo: \(canUndo), canRedo: \(canRedo)")
    }
  }
  // highlight-undoAndHistory-subscribe

  // highlight-undoAndHistory-createBlock
  let block = try engine.block.create(.graphic)
  try engine.block.setShape(block, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block, value: 100)
  try engine.block.setHeight(block, value: 100)
  try engine.block.setFill(block, fill: engine.block.createFill(.color))
  try engine.block.appendChild(to: page, child: block)
  // highlight-undoAndHistory-createBlock

  // highlight-undoAndHistory-undo
  if try engine.editor.canUndo() {
    try engine.editor.undo()
  }
  // highlight-undoAndHistory-undo

  // highlight-undoAndHistory-redo
  if try engine.editor.canRedo() {
    try engine.editor.redo()
  }
  // highlight-undoAndHistory-redo

  // highlight-undoAndHistory-manualStep
  try engine.block.setWidth(block, value: 200)
  try engine.editor.addUndoStep()
  // highlight-undoAndHistory-manualStep

  // highlight-undoAndHistory-removeStep
  if try engine.editor.canUndo() {
    try engine.editor.removeUndoStep()
  }
  // highlight-undoAndHistory-removeStep

  // highlight-undoAndHistory-multipleHistories
  let primaryHistory = engine.editor.getActiveHistory()
  let secondaryHistory = engine.editor.createHistory()
  engine.editor.setActiveHistory(secondaryHistory)

  // Operations here only affect secondaryHistory
  try engine.block.setWidth(block, value: 300)

  engine.editor.setActiveHistory(primaryHistory)
  engine.editor.destroyHistory(secondaryHistory)
  // highlight-undoAndHistory-multipleHistories

  historyTask.cancel()
}
