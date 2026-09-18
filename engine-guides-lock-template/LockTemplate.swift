import Foundation
import IMGLYEngine

@MainActor
func lockTemplate(engine: Engine) throws {
  let baseURL = try engine.guidesBaseURL
  let logoImage = baseURL.appendingPathComponent("ly.img.image/images/sample_1.jpg")

  // Build a brand template with a logo and a headline. New engine instances
  // start in the default Creator role.
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 500)
  try engine.block.appendChild(to: scene, child: page)

  let logo = try engine.block.create(.graphic)
  try engine.block.setShape(logo, shape: engine.block.createShape(.rect))
  let logoFill = try engine.block.createFill(.image)
  try engine.block.setURL(logoFill, property: "fill/image/imageFileURI", value: logoImage)
  try engine.block.setFill(logo, fill: logoFill)
  try engine.block.setPositionX(logo, value: 40)
  try engine.block.setPositionY(logo, value: 40)
  try engine.block.setWidth(logo, value: 120)
  try engine.block.setHeight(logo, value: 80)
  try engine.block.setName(logo, name: "Logo")
  try engine.block.appendChild(to: page, child: logo)

  let headline = try engine.block.create(.text)
  try engine.block.replaceText(headline, text: "Edit this headline")
  try engine.block.setFloat(headline, property: "text/fontSize", value: 48)
  try engine.block.setEnum(headline, property: "text/horizontalAlignment", value: "Center")
  try engine.block.setWidth(headline, value: 720)
  try engine.block.setHeightMode(headline, mode: .auto)
  try engine.block.setPositionX(headline, value: 40)
  try engine.block.setPositionY(headline, value: 200)
  try engine.block.setName(headline, name: "Headline")
  try engine.block.appendChild(to: page, child: headline)

  // highlight-lockTemplate-creatorSurface
  try engine.editor.setRole("Creator")

  let activeRole = try engine.editor.getRole()
  print("Active role:", activeRole) // Creator
  // highlight-lockTemplate-creatorSurface

  // highlight-lockTemplate-configureScopes
  try engine.block.setScopeEnabled(headline, key: "editor/select", enabled: true)
  try engine.block.setScopeEnabled(headline, key: "text/edit", enabled: true)

  let headlineIsSelectable = try engine.block.isScopeEnabled(headline, key: "editor/select")
  print("Headline editor/select enabled:", headlineIsSelectable) // true
  // highlight-lockTemplate-configureScopes

  // highlight-lockTemplate-adopterSurface
  try engine.editor.setRole("Adopter")

  let canEditHeadline = try engine.block.isAllowedByScope(headline, key: "text/edit")
  let canSelectLogo = try engine.block.isAllowedByScope(logo, key: "editor/select")
  let canMoveLogo = try engine.block.isAllowedByScope(logo, key: "layer/move")
  print("Adopter can edit the headline:", canEditHeadline) // true
  print("Adopter can select the logo:", canSelectLogo) // false
  print("Adopter can move the logo:", canMoveLogo) // false
  // highlight-lockTemplate-adopterSurface

  // highlight-lockTemplate-switchRoles
  try engine.editor.setRole("Creator")

  let creatorCanMoveLogo = try engine.block.isAllowedByScope(logo, key: "layer/move")
  let headlineStillEditable = try engine.block.isScopeEnabled(headline, key: "text/edit")
  print("Creator can move the logo:", creatorCanMoveLogo) // true
  print("Headline text/edit survived the switch:", headlineStillEditable) // true
  // highlight-lockTemplate-switchRoles
}
