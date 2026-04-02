// highlight-textEnumerations
import IMGLYEngine

@MainActor
func textEnumerations(engine: Engine) async throws {
  // highlight-textEnumerations-setup
  let scene = try engine.scene.create()
  let text = try engine.block.create(.text)
  try engine.block.appendChild(to: scene, child: text)
  try engine.block.setWidthMode(text, mode: .auto)
  try engine.block.setHeightMode(text, mode: .auto)
  try engine.block.replaceText(text, text: "First item\nSecond item\nThird item")
  // highlight-textEnumerations-setup

  // highlight-textEnumerations-applyListStyles
  // Apply ordered list style to all paragraphs (paragraphIndex defaults to -1 = all)
  try engine.block.setTextListStyle(text, listStyle: .ordered)

  // Override the third paragraph (index 2) to unordered
  try engine.block.setTextListStyle(text, listStyle: .unordered, paragraphIndex: 2)
  // highlight-textEnumerations-applyListStyles

  // highlight-textEnumerations-manageNesting
  // Set the second paragraph (index 1) to nesting level 1 (one indent deep)
  try engine.block.setTextListLevel(text, listLevel: 1, paragraphIndex: 1)

  // Read back the nesting level to confirm
  let level = try engine.block.getTextListLevel(text, paragraphIndex: 1)
  // level == 1
  // highlight-textEnumerations-manageNesting

  // highlight-textEnumerations-atomic
  // Atomically set both list style and nesting level in one call
  // Sets paragraph 0 to ordered style at nesting level 0 (outermost)
  try engine.block.setTextListStyle(text, listStyle: .ordered, paragraphIndex: 0, listLevel: 0)
  // highlight-textEnumerations-atomic

  // highlight-textEnumerations-paragraphIndices
  // Get all paragraph indices in the text block
  let allIndices = try engine.block.getTextParagraphIndices(text)
  // allIndices == [0, 1, 2]

  // Get indices overlapping a specific character subrange
  let content = try engine.block.getString(text, property: "text/text")
  let subrange = content.startIndex ..< content.index(content.startIndex, offsetBy: 10)
  let rangeIndices = try engine.block.getTextParagraphIndices(text, in: subrange)
  // rangeIndices == [0]
  // highlight-textEnumerations-paragraphIndices

  // highlight-textEnumerations-queryListStyles
  // Read back the list style and nesting level for each paragraph
  let styles = try allIndices.map { try engine.block.getTextListStyle(text, paragraphIndex: $0) }
  let levels = try allIndices.map { try engine.block.getTextListLevel(text, paragraphIndex: $0) }
  // styles == [.ordered, .ordered, .unordered]
  // levels == [0, 1, 0]
  // highlight-textEnumerations-queryListStyles

  _ = level
  _ = rangeIndices
  _ = styles
  _ = levels
}

// highlight-textEnumerations
