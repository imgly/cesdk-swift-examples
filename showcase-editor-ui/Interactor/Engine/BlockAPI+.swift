import Foundation
import IMGLYCore
import IMGLYEngine
import SwiftUI

// MARK: - Property mappings

/// Marker protocol for a type that is supported by the generic get/set `BlockAPI` methods.
public protocol MappedType: Equatable {}

extension MappedType {
  static var objectIdentifier: ObjectIdentifier { ObjectIdentifier(Self.self) }
}

extension Bool: MappedType {}
extension Int: MappedType {}
extension Float: MappedType {}
extension Double: MappedType {}
extension String: MappedType {}
extension URL: MappedType {}
extension RGBA: MappedType {}
extension CGColor: MappedType {}
extension SwiftUI.Color: MappedType {}
extension GradientColorStop: MappedType {}
extension Array: MappedType where Element: MappedType {}

/// Property block type to redirect the generic get/set `BlockAPI` methods.
public enum PropertyBlock {
  case fill, blur
}

public extension BlockAPI {
  private func unwrap<T>(_ value: T?) throws -> T {
    guard let value else {
      throw Error(errorDescription: "Unwrap failed.")
    }
    return value
  }

  private func resolve(_ propertyBlock: PropertyBlock?, parent: DesignBlockID) throws -> DesignBlockID {
    switch propertyBlock {
    case .none: return parent
    case .fill: return try getFill(parent)
    case .blur: return try getBlur(parent)
    }
  }

  func get<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: Property) throws -> T {
    try get(id, propertyBlock, property: property.rawValue)
  }

  // swiftlint:disable:next cyclomatic_complexity
  func get<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: String) throws -> T {
    let id = try resolve(propertyBlock, parent: id)
    let type = try getType(ofProperty: property)

    // Map enum types
    if type == .enum, let type = T.self as? any MappedEnum.Type {
      let rawValue = try getEnum(id, property: property)
      if let value = type.init(rawValue: rawValue) {
        return try unwrap(value as? T)
      } else {
        throw Error(
          // swiftlint:disable:next line_length
          errorDescription: "Unimplemented type mapping from raw value '\(rawValue)' to type '\(T.self)' for property '\(property)'."
        )
      }
    }
    // Map regular types
    switch (T.objectIdentifier, type) {
    case (Bool.objectIdentifier, .bool):
      return try unwrap(getBool(id, property: property) as? T)

    // .int mappings
    case (Int.objectIdentifier, .int):
      return try unwrap(getInt(id, property: property) as? T)
    case (Float.objectIdentifier, .int):
      return try unwrap(Float(getInt(id, property: property)) as? T)
    case (Double.objectIdentifier, .int):
      return try unwrap(Double(getInt(id, property: property)) as? T)

    // .float mappings
    case (Float.objectIdentifier, .float):
      return try unwrap(getFloat(id, property: property) as? T)
    case (Double.objectIdentifier, .float):
      return try unwrap(Double(getFloat(id, property: property)) as? T)

    // .double mappings
    case (Double.objectIdentifier, .double):
      return try unwrap(getDouble(id, property: property) as? T)

    // .string mappings
    case (String.objectIdentifier, .string):
      return try unwrap(getString(id, property: property) as? T)
    case (URL.objectIdentifier, .string):
      return try unwrap(URL(string: getString(id, property: property)) as? T)
    case (String.objectIdentifier, .enum):
      return try unwrap(getEnum(id, property: property) as? T)
    case (FillType.objectIdentifier, .string):
      return try unwrap(FillType(rawValue: getString(id, property: property)) as? T)

    // .color mappings
    case (RGBA.objectIdentifier, .color):
      return try unwrap(getColor(id, property: property) as RGBA as? T)
    case (CGColor.objectIdentifier, .color):
      return try unwrap(getColor(id, property: property).color() as? T)
    case (SwiftUI.Color.objectIdentifier, .color):
      return try unwrap(SwiftUI.Color(cgColor: getColor(id, property: property).color()) as? T)

    // .struct mappings
    case ([GradientColorStop].objectIdentifier, .struct):
      return try unwrap(getGradientColorStops(id, property: property) as? T)
    default:
      throw Error(
        // swiftlint:disable:next line_length
        errorDescription: "Unimplemented type mapping from block property type '\(type)' to type '\(T.self)' for property '\(property)'."
      )
    }
  }

  func set(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
           property: Property, value: some MappedType) throws {
    try set(id, propertyBlock, property: property.rawValue, value: value)
  }

  // swiftlint:disable:next cyclomatic_complexity
  func set<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: String, value: T) throws {
    let parentId = id
    let id = try resolve(propertyBlock, parent: id)
    let type = try getType(ofProperty: property)

    // Map enum types
    if type == .enum, let value = value as? any MappedEnum {
      try setEnum(id, property: property, value: value.rawValue)
      return
    }
    // Map regular types
    switch (T.objectIdentifier, type) {
    case (Bool.objectIdentifier, .bool):
      try setBool(id, property: property, value: unwrap(value as? Bool))

    // .int mappings
    case (Int.objectIdentifier, .int):
      try setInt(id, property: property, value: unwrap(value as? Int))
    case (Float.objectIdentifier, .int):
      try setInt(id, property: property, value: Int(unwrap(value as? Float)))
    case (Double.objectIdentifier, .int):
      try setInt(id, property: property, value: Int(unwrap(value as? Double)))

    // .float mappings
    case (Float.objectIdentifier, .float):
      try setFloat(id, property: property, value: unwrap(value as? Float))
    case (Double.objectIdentifier, .float):
      try setFloat(id, property: property, value: Float(unwrap(value as? Double)))

    // .double mappings
    case (Double.objectIdentifier, .double):
      try setDouble(id, property: property, value: unwrap(value as? Double))

    // .string mappings
    case (String.objectIdentifier, .string):
      try setString(id, property: property, value: unwrap(value as? String))
    case (URL.objectIdentifier, .string):
      try setString(id, property: property, value: unwrap(value as? URL).absoluteString)
    case (String.objectIdentifier, .enum):
      try setEnum(id, property: property, value: unwrap(value as? String))
    case (FillType.objectIdentifier, .string):
      let fillType = try unwrap(value as? FillType)
      if fillType == .none {
        try setFillEnabled(parentId, enabled: false)
      } else {
        if try hasFill(parentId) {
          try destroy(getFill(parentId))
        }
        let newFill = try createFill(fillType.rawValue)
        try setFill(parentId, fill: newFill)
      }

    // .color mappings
    case (RGBA.objectIdentifier, .color):
      let color = try unwrap(value as? RGBA)
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    case (CGColor.objectIdentifier, .color):
      // swiftlint:disable:next force_cast
      let color = try (value as! CGColor).rgba()
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    case (Color.objectIdentifier, .color):
      let color = try unwrap(value as? SwiftUI.Color).asCGColor.rgba()
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)

    // .struct mappings
    case ([GradientColorStop].objectIdentifier, .struct):
      let colorStops = try unwrap(value as? [GradientColorStop])
      try setGradientColorStops(id, property: property, colors: colorStops)
    default:
      throw Error(
        // swiftlint:disable:next line_length
        errorDescription: "Unimplemented type mapping to block property type '\(type)' from type '\(T.self)' for property '\(property)'."
      )
    }
  }

  func set(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
           property: Property, value: some MappedType) throws -> Bool {
    try set(ids, propertyBlock, property: property.rawValue, value: value)
  }

  func set(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
           property: String, value: some MappedType) throws -> Bool {
    let changed = try ids.filter {
      try get($0, propertyBlock, property: property) != value
    }
    try changed.forEach {
      try set($0, propertyBlock, property: property, value: value)
    }
    return !changed.isEmpty
  }

  func enumValues<T>(property: Property) throws -> [T]
    where T: CaseIterable & RawRepresentable, T.RawValue == String {
    try enumValues(property: property.rawValue)
  }

  /// Get all enum cases orderend as defined by the enum `type` `T` and verify if all cases for the `property` are
  /// mapped.
  func enumValues<T>(property: String) throws -> [T]
    where T: CaseIterable & RawRepresentable, T.RawValue == String {
    let orderedCases = T.allCases.map { $0 } // Same order as defined in enum types.
    let cases = Set<String>(orderedCases.map(\.rawValue))
    let values = Set<String>(try getEnumValues(ofProperty: property))
    let unmappedValues = values.subtracting(cases)
    let unmappedCases = cases.subtracting(values)

    guard unmappedValues.isEmpty, unmappedCases.isEmpty else {
      var message = "Encountered "
      if !unmappedValues.isEmpty {
        message += "unmapped raw values: '\(unmappedValues.sorted())'"
      }
      if !unmappedValues.isEmpty, !unmappedCases.isEmpty {
        message += " and "
      }
      if !unmappedCases.isEmpty {
        message += "unmapped raw representable cases: '\(unmappedCases.sorted())'"
      }
      throw Error(errorDescription: message + " while mapping enum property '\(property)' to type '\(T.self)'.")
    }
    return orderedCases
  }
}

// MARK: - Crop

extension BlockAPI {
  func canResetCrop(_ id: DesignBlockID) throws -> Bool {
    try getContentFillMode(id) == .crop
  }
}

// MARK: - Layering

extension BlockAPI {
  func canBringForward(_ id: DesignBlockID) throws -> Bool {
    guard let parent = try getParent(id) else {
      return false
    }
    let children = try getChildren(parent)
    return children.last != id
  }

  func canBringBackward(_ id: DesignBlockID) throws -> Bool {
    guard let parent = try getParent(id) else {
      return false
    }
    let children = try getChildren(parent)
    return children.first != id
  }

  func bringToFront(_ id: DesignBlockID) throws {
    guard let parent = try getParent(id) else {
      return
    }
    let children = try getChildren(parent)
    if let index = children.firstIndex(of: id), index < children.endIndex - 1 {
      try appendChild(to: parent, child: id)
    }
  }

  func bringForward(_ id: DesignBlockID) throws {
    guard let parent = try getParent(id) else {
      return
    }
    let children = try getChildren(parent)
    if let index = children.firstIndex(of: id), index < children.endIndex - 1 {
      try insertChild(into: parent, child: id, at: index + 1)
    }
  }

  func sendBackward(_ id: DesignBlockID) throws {
    guard let parent = try getParent(id) else {
      return
    }
    let children = try getChildren(parent)
    if let index = children.firstIndex(of: id), index > 0 {
      try insertChild(into: parent, child: id, at: index - 1)
    }
  }

  func sendToBack(_ id: DesignBlockID) throws {
    guard let parent = try getParent(id) else {
      return
    }
    let children = try getChildren(parent)
    if let index = children.firstIndex(of: id), index > 0 {
      try insertChild(into: parent, child: id, at: 0)
    }
  }
}

// MARK: - Scopes

public extension BlockAPI {
  func overrideAndRestore<T>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                             scope: Scope,
                             action: (DesignBlockID) throws -> T) throws -> T {
    let action: ([DesignBlockID]) throws -> T = { ids in try action(ids.first!) }
    return try overrideAndRestore([id], propertyBlock, scopes: [scope], action: action)
  }

  func overrideAndRestore<T>(_ ids: [DesignBlockID], _ propertyBlock: PropertyBlock? = nil,
                             scope: Scope,
                             action: ([DesignBlockID]) throws -> T) throws -> T {
    try overrideAndRestore(ids, propertyBlock, scopes: [scope], action: action)
  }

  func overrideAndRestore<T>(_ ids: [DesignBlockID],
                             _ propertyBlock: PropertyBlock? = nil,
                             scopes: Set<Scope>,
                             action: ([DesignBlockID]) throws -> T) throws -> T {
    let resolvedIds = try ids.map { try resolve(propertyBlock, parent: $0) }
    let enabledScopesPerID = try resolvedIds.map { id in
      let enabledScopes = try scopes.map { scope in
        let wasEnabled = try isScopeEnabled(id, key: scope.rawValue)
        try setScopeEnabled(id, key: scope.rawValue, enabled: true)
        return (scope: scope, isEnabled: wasEnabled)
      }
      return (id: id, enabledScopes: enabledScopes)
    }

    let result = try action(resolvedIds)

    try enabledScopesPerID.forEach { id, enabledScopes in
      try enabledScopes.forEach { scope, isEnabled in
        if isValid(id) {
          try setScopeEnabled(id, key: scope.rawValue, enabled: isEnabled)
        }
      }
    }

    return result
  }

  func overrideAndRestore(_ id: DesignBlockID, scope: Scope,
                          action: (DesignBlockID) async throws -> Void) async throws {
    try await overrideAndRestore(id, scopes: [scope], action: action)
  }

  func overrideAndRestore(_ id: DesignBlockID, scopes: Set<Scope>,
                          action: (DesignBlockID) async throws -> Void) async throws {
    let enabledScopes = try scopes.map { scope in
      let wasEnabled = try isScopeEnabled(id, key: scope.rawValue)
      try setScopeEnabled(id, key: scope.rawValue, enabled: true)
      return (scope: scope, isEnabled: wasEnabled)
    }

    try await action(id)

    try enabledScopes.forEach { scope, isEnabled in
      if isValid(id) {
        try setScopeEnabled(id, key: scope.rawValue, enabled: isEnabled)
      }
    }
  }
}

// MARK: - Utilities

extension BlockAPI {
  public func deselectAll() throws {
    try findAllSelected().forEach {
      try setSelected($0, selected: false)
    }
  }

  func isGrouped(_ id: DesignBlockID) throws -> Bool {
    guard let parent = try getParent(id) else {
      return false
    }
    let type = try getType(parent)
    return type == DesignBlockType.group.rawValue
  }

  func addOutline(_ name: String? = nil, for id: DesignBlockID, to parent: DesignBlockID) throws -> DesignBlockID {
    let outline = try create(.rectShape)

    let height = try getHeight(id)
    let width = try getWidth(id)

    if let name {
      try setName(outline, name: name)
    }
    try setHeightMode(outline, mode: .absolute)
    try setHeight(outline, value: height)
    try setWidthMode(outline, mode: .absolute)
    try setWidth(outline, value: width)
    try appendChild(to: parent, child: outline)

    try set(outline, property: .key(.fillEnabled), value: false)
    try set(outline, property: .key(.strokeEnabled), value: true)
    try set(outline, property: .key(.strokeColor), value: CGColor.white)
    try set(outline, property: .key(.strokeStyle), value: StrokeStyle.dotted)
    try set(outline, property: .key(.strokeWidth), value: 1.0)
    try set(outline, property: .key(.blendMode), value: BlendMode.difference)
    try setScopeEnabled(outline, key: ScopeKey.editorSelect.rawValue, enabled: false)

    return outline
  }
}
