import Foundation
import IMGLYCore

public typealias Property = RawRepresentableKey<PropertyKey>

public enum PropertyKey: String {
  case fillEnabled = "fill/enabled"
  case fillSolidColor = "fill/solid/color"
  case fillGradientColors = "fill/gradient/colors"

  case fillGradientLinearStartX = "fill/gradient/linear/startPointX"
  case fillGradientLinearStartY = "fill/gradient/linear/startPointY"
  case fillGradientLinearEndX = "fill/gradient/linear/endPointX"
  case fillGradientLinearEndY = "fill/gradient/linear/endPointY"

  case fillImageImageFileURI = "fill/image/imageFileURI"

  case strokeEnabled = "stroke/enabled"
  case strokeColor = "stroke/color"
  case strokeWidth = "stroke/width"
  case strokeStyle = "stroke/style"
  case strokePosition = "stroke/position"
  case strokeCornerGeometry = "stroke/cornerGeometry"

  case opacity

  case blendMode = "blend/mode"

  case heightMode = "height/mode"

  case lastFrameHeight = "lastFrame/height"

  case textFontFileURI = "text/fontFileUri"
  case textFontSize = "text/fontSize"
  case textHorizontalAlignment = "text/horizontalAlignment"
  case textLetterSpacing = "text/letterSpacing"
  case textLineHeight = "text/lineHeight"
  case textVerticalAlignment = "text/verticalAlignment"

  case shapeStarPoints = "shape/star/points"
  case shapeStarInnerDiameter = "shape/star/innerDiameter"
  case shapePolygonSides = "shape/polygon/sides"

  case sceneDesignUnit = "scene/designUnit"
  case sceneDPI = "scene/dpi"

  case stackAxis = "stack/axis"
  case stackSpacing = "stack/spacing"
  case stackSpacingInScreenspace = "stack/spacingInScreenspace"

  case cropRotation = "crop/rotation"
  case cropScaleRatio = "crop/scaleRatio"

  case type
}

extension Property {
  var enabled: Property? {
    switch rawValue {
    case _ where rawValue.hasPrefix("fill/"): return .key(.fillEnabled)
    case _ where rawValue.hasPrefix("stroke/"): return .key(.strokeEnabled)
    default: return nil
    }
  }
}
