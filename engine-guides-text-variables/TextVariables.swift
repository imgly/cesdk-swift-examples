import Foundation
import IMGLYEngine

@MainActor
func textVariables(engine: Engine) async throws {
  // Clear any leftover sample keys so the example is idempotent on repeat runs.
  for key in ["firstName", "lastName"] where engine.variable.findAll().contains(key) {
    try engine.variable.remove(key: key)
  }

  // Build a certificate-sized template page to hold the tokenized heading.
  // A Pixel design unit interprets the width, height, and font sizes below in
  // pixels, so the heading renders at a predictable size.
  let scene = try engine.scene.create(designUnit: .px)
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 260)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-textVariables-bind-tokens
  let textBlock = try engine.block.create(.text)
  try engine.block.replaceText(textBlock, text: "Certificate for {{firstName}} {{lastName}}")
  try engine.block.setPositionX(textBlock, value: 60)
  try engine.block.setPositionY(textBlock, value: 105)
  try engine.block.setWidth(textBlock, value: 680)
  try engine.block.setHeightMode(textBlock, mode: .auto)
  try engine.block.setTextFontSize(textBlock, fontSize: 42)
  try engine.block.setTextColor(textBlock, color: .rgba(r: 0.078, g: 0.09, b: 0.122, a: 1))
  try engine.block.appendChild(to: page, child: textBlock)
  // highlight-textVariables-bind-tokens

  // highlight-textVariables-set-values
  let recipient = ["firstName": "Alex", "lastName": "Smith"]
  for (key, value) in recipient {
    try engine.variable.set(key: key, value: value)
  }
  // highlight-textVariables-set-values

  // With both variables seeded, the page renders the resolved heading.
  try await engine.captureGuide(page, label: "hero")

  // highlight-textVariables-discover-variables
  let variableNames = engine.variable.findAll().sorted()
  print("Stored variables:", variableNames) // ["firstName", "lastName"]
  // highlight-textVariables-discover-variables

  // highlight-textVariables-read-variable
  let firstName = try engine.variable.get(key: "firstName")
  print("firstName:", firstName) // "Alex"
  // highlight-textVariables-read-variable

  // highlight-textVariables-detect-references
  let hasVariableReferences = try engine.block.referencesAnyVariables(textBlock)
  print("Heading references variables:", hasVariableReferences) // true
  // highlight-textVariables-detect-references

  // highlight-textVariables-scan-tokens
  let tokenPattern = try NSRegularExpression(pattern: #"\{\{\s*([^{}]+?)\s*\}\}"#)
  let tokenKeys = try engine.block.find(byType: .text).flatMap { block -> [String] in
    let content = try engine.block.getString(block, property: "text/text")
    let range = NSRange(content.startIndex ..< content.endIndex, in: content)
    return tokenPattern.matches(in: content, range: range).compactMap { match in
      Range(match.range(at: 1), in: content).map { String(content[$0]) }
    }
  }
  print("Tokens in scene:", tokenKeys) // ["firstName", "lastName"]
  // highlight-textVariables-scan-tokens

  // highlight-textVariables-remove-variable
  try engine.variable.remove(key: "lastName")
  let remainingVariables = engine.variable.findAll().sorted()
  print("Variables after removal:", remainingVariables) // ["firstName"]
  // highlight-textVariables-remove-variable
}
