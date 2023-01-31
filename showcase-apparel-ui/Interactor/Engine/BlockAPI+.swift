import Foundation
import IMGLYEngine
import SwiftUI

/// Marker protocol for a type that is supported by the generic get/set `BlockAPI` methods.
protocol MappedType: Equatable {}

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
extension Color: MappedType {}

/// Property block type to redirect the generic get/set `BlockAPI` methods.
enum PropertyBlock {
  case fill, blur
}

extension BlockAPI {
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

  // swiftlint:disable:next cyclomatic_complexity
  func get<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: String) throws -> T {
    let id = try resolve(propertyBlock, parent: id)
    let type = try getType(ofProperty: property)

    // Map enum types
    if type == .enum, let type = T.self as? any RawRepresentable<String>.Type {
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
    case (Int.objectIdentifier, .int):
      return try unwrap(getInt(id, property: property) as? T)
    case (Float.objectIdentifier, .float):
      return try unwrap(getFloat(id, property: property) as? T)
    case (Double.objectIdentifier, .double):
      return try unwrap(getDouble(id, property: property) as? T)
    case (String.objectIdentifier, .string):
      return try unwrap(getString(id, property: property) as? T)
    case (URL.objectIdentifier, .string):
      return try unwrap(URL(string: getString(id, property: property)) as? T)
    case (String.objectIdentifier, .enum):
      return try unwrap(getEnum(id, property: property) as? T)
    case (RGBA.objectIdentifier, .color):
      return try unwrap(getColor(id, property: property) as? T)
    case (CGColor.objectIdentifier, .color):
      return try unwrap(getColor(id, property: property).color() as? T)
    case (Color.objectIdentifier, .color):
      return try unwrap(Color(cgColor: getColor(id, property: property).color()) as? T)
    default:
      throw Error(
        // swiftlint:disable:next line_length
        errorDescription: "Unimplemented type mapping from block property type '\(type)' to type '\(T.self)' for property '\(property)'."
      )
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  func set<T: MappedType>(_ id: DesignBlockID, _ propertyBlock: PropertyBlock? = nil,
                          property: String, value: T) throws {
    let id = try resolve(propertyBlock, parent: id)
    let type = try getType(ofProperty: property)

    // Map enum types
    if type == .enum, let value = value as? any RawRepresentable<String> {
      try setEnum(id, property: property, value: value.rawValue)
      return
    }
    // Map regular types
    switch (T.objectIdentifier, type) {
    case (Bool.objectIdentifier, .bool):
      try setBool(id, property: property, value: unwrap(value as? Bool))
    case (Int.objectIdentifier, .int):
      try setInt(id, property: property, value: unwrap(value as? Int))
    case (Float.objectIdentifier, .float):
      try setFloat(id, property: property, value: unwrap(value as? Float))
    case (Double.objectIdentifier, .double):
      try setDouble(id, property: property, value: unwrap(value as? Double))
    case (String.objectIdentifier, .string):
      try setString(id, property: property, value: unwrap(value as? String))
    case (URL.objectIdentifier, .string):
      try setString(id, property: property, value: unwrap(value as? URL).absoluteString)
    case (String.objectIdentifier, .enum):
      try setEnum(id, property: property, value: unwrap(value as? String))
    case (RGBA.objectIdentifier, .color):
      let color = try unwrap(value as? RGBA)
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    case (CGColor.objectIdentifier, .color):
      // swiftlint:disable:next force_cast
      let color = try (value as! CGColor).rgba()
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    case (Color.objectIdentifier, .color):
      let color = try unwrap(value as? Color).asCGColor.rgba()
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    default:
      throw Error(
        // swiftlint:disable:next line_length
        errorDescription: "Unimplemented type mapping to block property type '\(type)' from type '\(T.self)' for property '\(property)'."
      )
    }
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
