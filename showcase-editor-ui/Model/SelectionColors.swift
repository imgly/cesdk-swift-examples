import CoreGraphics

public struct SelectionColors {
  typealias Blocks = [Interactor.BlockID]
  typealias Properties = [Property: Blocks]
  typealias Colors = [CGColor: Properties]
  typealias NamedColors = [String: Colors]

  private var namedColors: NamedColors = [:]

  subscript(name: String, color: CGColor) -> Properties? {
    namedColors[name]?[color]
  }

  mutating func add(_ id: Interactor.BlockID, property: Property, value color: CGColor, name: String) {
    let selectionColor = [name: [color: [property: [id]]]]

    namedColors.merge(selectionColor) { currentName, newName in
      currentName.merging(newName) { currentProperty, newProperty in
        currentProperty.merging(newProperty) { currentBlock, newBlock in
          currentBlock + newBlock
        }
      }
    }
  }

  var isEmpty: Bool { namedColors.isEmpty }

  private func sort(colors all: Set<CGColor>) -> [CGColor] {
    let transparent = all.filter(HSBA.predicate(\.isTransparent))
    let opaque = all.subtracting(transparent)
    let gray = opaque.filter(HSBA.predicate(\.isGray))
    let colors = opaque.subtracting(gray)

    let sortedTransparent = transparent.sorted(by: HSBA.comparator(\.alpha, order: .reverse))
    let sortedGray = gray.sorted(by: HSBA.comparator(\.brightness))
    let sortedColors = colors.sorted(by: HSBA.comparator(\.hue))
    let sorted = sortedGray + sortedColors + sortedTransparent

    assert(all.count == sorted.count)
    return sorted
  }

  var sorted: [(name: String, colors: [CGColor])] {
    var namedColors = namedColors
    let unnamedColors = namedColors.removeValue(forKey: "")

    let named = namedColors.keys.sorted().compactMap { name in
      if let colors = namedColors[name] {
        return (name: name, colors: sort(colors: Set(colors.keys)))
      } else {
        return nil
      }
    }

    if let unnamedColors {
      return named + [(name: "", colors: sort(colors: Set(unnamedColors.keys)))]
    } else {
      return named
    }
  }

  var sortedByColor: [CGColor] {
    let colors = namedColors.flatMap { _, colors in
      colors.keys
    }
    return sort(colors: Set(colors))
  }
}

extension SelectionColors: CustomDebugStringConvertible {
  public var debugDescription: String {
    var string = "namedColors: \(namedColors.count)\n"
    namedColors.forEach { name, colors in
      string += " name: \(name) colors: \(colors.count)\n"
      colors.forEach { color, properties in
        string += "  color: \(color.components ?? []) properties: \(properties.count)\n"
        properties.forEach { property, blocks in
          string += "   property: \(property.rawValue) blocks: \(blocks)\n"
        }
      }
    }
    return string
  }
}
