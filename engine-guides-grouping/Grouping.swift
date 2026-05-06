import IMGLYEngine

@MainActor
func grouping(engine: Engine) async throws {
  let scene = try engine.scene.create()

  let page = try engine.block.create(.page)
  try engine.block.setWidth(page, value: 800)
  try engine.block.setHeight(page, value: 600)
  try engine.block.appendChild(to: scene, child: page)

  // highlight-grouping-createBlocks
  // Create a graphic block with a colored rectangle shape
  let block1 = try engine.block.create(.graphic)
  try engine.block.setShape(block1, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block1, value: 120)
  try engine.block.setHeight(block1, value: 120)
  try engine.block.setPositionX(block1, value: 200)
  try engine.block.setPositionY(block1, value: 240)
  let fill1 = try engine.block.createFill(.color)
  try engine.block.setColor(fill1, property: "fill/color/value", color: .rgba(r: 0.4, g: 0.6, b: 0.9, a: 1.0))
  try engine.block.setFill(block1, fill: fill1)
  try engine.block.appendChild(to: page, child: block1)
  // highlight-grouping-createBlocks

  // Create two more blocks for grouping
  let block2 = try engine.block.create(.graphic)
  try engine.block.setShape(block2, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block2, value: 120)
  try engine.block.setHeight(block2, value: 120)
  try engine.block.setPositionX(block2, value: 340)
  try engine.block.setPositionY(block2, value: 240)
  let fill2 = try engine.block.createFill(.color)
  try engine.block.setColor(fill2, property: "fill/color/value", color: .rgba(r: 0.9, g: 0.5, b: 0.4, a: 1.0))
  try engine.block.setFill(block2, fill: fill2)
  try engine.block.appendChild(to: page, child: block2)

  let block3 = try engine.block.create(.graphic)
  try engine.block.setShape(block3, shape: engine.block.createShape(.rect))
  try engine.block.setWidth(block3, value: 120)
  try engine.block.setHeight(block3, value: 120)
  try engine.block.setPositionX(block3, value: 480)
  try engine.block.setPositionY(block3, value: 240)
  let fill3 = try engine.block.createFill(.color)
  try engine.block.setColor(fill3, property: "fill/color/value", color: .rgba(r: 0.5, g: 0.8, b: 0.5, a: 1.0))
  try engine.block.setFill(block3, fill: fill3)
  try engine.block.appendChild(to: page, child: block3)

  // highlight-grouping-checkGroupable
  // Check if the blocks can be grouped together
  let canGroup = try engine.block.isGroupable([block1, block2, block3])
  print("Blocks can be grouped:", canGroup)
  // highlight-grouping-checkGroupable

  // highlight-grouping-createGroup
  // Group the blocks together
  if canGroup {
    let groupID = try engine.block.group([block1, block2, block3])
    print("Created group with ID:", groupID)

    // Select the group to show it in the UI
    try engine.block.setSelected(groupID, selected: true)
    // highlight-grouping-createGroup

    // highlight-grouping-enterGroup
    // Enter the group to select individual members
    try engine.block.enterGroup(groupID)

    // Select a specific member within the group
    try engine.block.setSelected(block2, selected: true)
    print("Selected member inside group")
    // highlight-grouping-enterGroup

    // highlight-grouping-exitGroup
    // Exit the group to return selection to the parent group
    try engine.block.exitGroup(block2)
    print("Exited group, group is now selected")
    // highlight-grouping-exitGroup

    // highlight-grouping-findGroups
    // Find all groups in the scene
    let allGroups = try engine.block.find(byType: .group)
    print("Number of groups in scene:", allGroups.count)

    // Check the type of the group block
    let groupType = try engine.block.getType(groupID)
    print("Group block type:", groupType)

    // Get the members of the group
    let members = try engine.block.getChildren(groupID)
    print("Group has", members.count, "members")
    // highlight-grouping-findGroups

    // highlight-grouping-ungroup
    // Ungroup the blocks to make them independent again
    try engine.block.ungroup(groupID)
    print("Ungrouped blocks")

    // Verify blocks are no longer in a group
    let groupsAfterUngroup = try engine.block.find(byType: .group)
    print("Groups after ungrouping:", groupsAfterUngroup.count)
    // highlight-grouping-ungroup

    // Re-group for the final display
    let finalGroup = try engine.block.group([block1, block2, block3])
    try engine.block.setSelected(finalGroup, selected: true)
  }

  // highlight-grouping-zoom
  try await engine.scene.zoom(to: page, paddingLeft: 40, paddingTop: 40, paddingRight: 40, paddingBottom: 40)
  // highlight-grouping-zoom
}
