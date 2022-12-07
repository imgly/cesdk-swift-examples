import Foundation
import IMGLYEngine

extension BlockAPI {
  private func unwrap<T>(_ value: T?) throws -> T {
    guard let value else {
      throw Error(errorDescription: "Unwrap failed.")
    }
    return value
  }

  func get<T>(_ id: DesignBlockID, property: String) throws -> T {
    let type = try getType(ofProperty: property)
    switch (T.self, type) {
    case (is Bool.Type, .bool): return try unwrap(getBool(id, property: property) as? T)
    case (is Int.Type, .int): return try unwrap(getInt(id, property: property) as? T)
    case (is Float.Type, .float): return try unwrap(getFloat(id, property: property) as? T)
    case (is Double.Type, .double): return try unwrap(getDouble(id, property: property) as? T)
    case (is String.Type, .string): return try unwrap(getString(id, property: property) as? T)
    case (is URL.Type, .string): return try unwrap(URL(string: getString(id, property: property)) as? T)
    case (is String.Type, .enum): return try unwrap(getEnum(id, property: property) as? T)
    case (is RGBA.Type, .color): return try unwrap(getColor(id, property: property) as? T)
    default:
      throw Error(errorDescription: "Unsupported type.")
    }
  }

  func set<T>(_ id: DesignBlockID, property: String, value: T) throws {
    let type = try getType(ofProperty: property)
    switch (T.self, type) {
    case (is Bool.Type, .bool): try setBool(id, property: property, value: unwrap(value as? Bool))
    case (is Int.Type, .int): try setInt(id, property: property, value: unwrap(value as? Int))
    case (is Float.Type, .float): try setFloat(id, property: property, value: unwrap(value as? Float))
    case (is Double.Type, .double): try setDouble(id, property: property, value: unwrap(value as? Double))
    case (is String.Type, .string): try setString(id, property: property, value: unwrap(value as? String))
    case (is URL.Type, .string): try setString(id, property: property, value: unwrap(value as? URL).absoluteString)
    case (is String.Type, .enum): try setEnum(id, property: property, value: unwrap(value as? String))
    case (is RGBA.Type, .color):
      let color = try unwrap(value as? RGBA)
      try setColor(id, property: property, r: color.r, g: color.g, b: color.b, a: color.a)
    default:
      throw Error(errorDescription: "Unsupported type.")
    }
  }
}
