import SwiftUI

struct FillAndStrokeOptions: View {
  typealias GradientColorStop = Interactor.GradientColorStop
  typealias Color = Interactor.Color

  @EnvironmentObject private var interactor: Interactor
  @Environment(\.selection) private var id

  @ViewBuilder var fillAndStrokeOptions: some View {
    if interactor.hasFill(id) {
      Section("Fill") {
        let fillType: Binding<ColorFillType?> = interactor
          .bind(id, property: .key(.fillType), getter: fillTypeGetter, setter: fillTypeSetter)
        FillColorOptions(fillType: fillType)
      }
    }
    if interactor.hasStroke(id) {
      Section("Stroke") {
        StrokeOptions(isEnabled: interactor.bind(id, property: .key(.strokeEnabled), default: false))
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Stroke")
    }
  }

  var body: some View {
    List {
      fillAndStrokeOptions
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless) // or .plain will do the job
    }
  }

  // MARK: - Getter/Setter

  // The `PropertyGetter` for retrieving the fill type.
  let fillTypeGetter: Interactor.PropertyGetter<ColorFillType> = { engine, id, _, _ in
    let fillEnabled = try engine.block.isFillEnabled(id)
    if !fillEnabled { return ColorFillType.none }
    return try engine.block.get(id, property: .key(.fillType))
  }

  // The `PropertySetter` for setting the fill type.
  let fillTypeSetter: Interactor.PropertySetter<ColorFillType> = { engine, blocks, _, _, value, completion in
    let isNone = value == ColorFillType.none
    let fallbackValue = ColorFillType.solid

    let changed = try blocks.filter {
      let fillType: ColorFillType = try engine.block.get($0, property: .key(.fillType))
      let enabledChanged = try engine.block.isFillEnabled($0) == isNone
      let hasChanged = fillType != (isNone ? fallbackValue : value) || enabledChanged
      return hasChanged
    }

    try changed.forEach {
      var colorStops: [GradientColorStop]?
      var solidColor: Color?

      let currentFillType: ColorFillType = try engine.block.get($0, property: .key(.fillType))
      if currentFillType != .gradient, value == .gradient {
        let currentSolidFill = try engine.block.getFillSolidColor($0)
        let newColor = try currentSolidFill.changeBrightness(by: 0.4)
        colorStops = [
          .init(
            color: Color
              .rgba(r: currentSolidFill.r, g: currentSolidFill.g, b: currentSolidFill.b, a: currentSolidFill.a),
            stop: 0
          ),
          .init(color: Color.rgba(r: newColor.r, g: newColor.g, b: newColor.b, a: newColor.a), stop: 1)
        ]
      } else if value == .solid, currentFillType == .gradient {
        let currentColorStops: [GradientColorStop] = try engine.block
          .get($0, .fill, property: .key(.fillGradientColors))
        solidColor = currentColorStops.first?.color
      }

      try engine.block.set(
        $0,
        property: Property(.fillType),
        value: isNone ? fallbackValue : value
      )

      if let colorStops {
        try engine.block.set($0, .fill, property: .key(.fillGradientColors), value: colorStops)
      } else if let color = try solidColor?.cgColor?.rgba() {
        try engine.block.setFillSolidColor($0, r: color.r, g: color.g, b: color.b, a: color.a)
      }

      try engine.block.setFillEnabled($0, enabled: !isNone)
    }
    let didChange = !changed.isEmpty
    return try (completion?(engine, blocks, didChange) ?? false) || didChange
  }
}
