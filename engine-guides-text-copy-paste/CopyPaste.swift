import Foundation
import IMGLYEngine

struct CopyPasteGuideResult {
  let source: DesignBlockID
  let target: DesignBlockID
  let headline: DesignBlockID
  let pasted: DesignBlockID
  let note: DesignBlockID
}

@MainActor
func copyPaste(engine: Engine) throws -> CopyPasteGuideResult {
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // Five auto-sized text blocks, one below the other.
  let content = "Summer Sale\nNew colors\nFree shipping"
  let blocks = try [(content, 40.0), ("", 200.0), ("Today: ", 360.0), ("", 440.0), ("Caption", 520.0)]
    .map { text, y in
      let block = try engine.block.create(.text)
      try engine.block.appendChild(to: page, child: block)
      try engine.block.setWidthMode(block, mode: .auto)
      try engine.block.setHeightMode(block, mode: .auto)
      try engine.block.setPositionX(block, value: 40)
      try engine.block.setPositionY(block, value: Float(y))
      try engine.block.replaceText(block, text: text)
      return block
    }
  let (source, target, headline, pasted, note) = (blocks[0], blocks[1], blocks[2], blocks[3], blocks[4])

  // The source block carries a red title, an underlined word and a bulleted list.
  let title = content.range(of: "Summer Sale")!
  try engine.block.setTextColor(source, color: .rgba(r: 1, g: 0, b: 0, a: 1), in: title)
  try engine.block.toggleTextDecorationUnderline(source, in: content.range(of: "New colors")!)
  try engine.block.setTextListStyle(source, listStyle: .unordered, paragraphIndex: 1)
  try engine.block.setTextListStyle(source, listStyle: .unordered, paragraphIndex: 2)

  // highlight-copyPaste-copyText
  // Copy the whole text with every run and paragraph format
  let copiedHTML = try engine.block.getTextAsHTML(source)
  // highlight-copyPaste-copyText

  // highlight-copyPaste-pasteText
  // Replace the whole text of the target block with the copied text
  try engine.block.replaceTextWithHTML(target, html: copiedHTML)
  // highlight-copyPaste-pasteText

  // highlight-copyPaste-copyRange
  // Copy only "Summer Sale" and insert it at the end of the headline
  let titleHTML = try engine.block.getTextAsHTML(source, in: title)
  let headlineText = try engine.block.getString(headline, property: "text/text")
  try engine.block.replaceTextWithHTML(
    headline,
    html: titleHTML,
    in: headlineText.endIndex ..< headlineText.endIndex,
  )
  // highlight-copyPaste-copyRange

  // highlight-copyPaste-pasteHTML
  // HTML as a browser or a document app puts it on the clipboard, with its font size and line height
  let clipboardHTML = #"<p style="line-height:1.5"><b style="font-size:24px">Bold</b> and "#
    + #"<span style="color:#ff0000">red</span></p><ul><li>item</li></ul>"#
  try engine.block.replaceTextWithHTML(pasted, html: clipboardHTML)
  // highlight-copyPaste-pasteHTML

  // highlight-copyPaste-fallback
  // A copied image puts HTML without text on the clipboard
  let imageHTML = #"<p><img src="https://example.com/photo.png"></p>"#
  let imagePlainText = "Beach photo"
  do {
    try engine.block.replaceTextWithHTML(note, html: imageHTML)
  } catch let error as EngineError where error.catalogCode == .blockTextHtmlHasNoText {
    // The block is unchanged, so insert the plain text of the clipboard instead
    try engine.block.replaceText(note, text: imagePlainText)
  }
  // highlight-copyPaste-fallback

  return CopyPasteGuideResult(source: source, target: target, headline: headline, pasted: pasted, note: note)
}
