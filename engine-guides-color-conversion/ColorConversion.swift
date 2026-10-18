import Foundation
import IMGLYEngine

@MainActor
func colorConversion(engine: Engine) async throws {
  // highlight-colorConversion-defineSpot
  engine.editor.setSpotColor(name: "Brand Red", r: 0.8, g: 0.1, b: 0.1)
  engine.editor.setSpotColor(name: "Brand Red", c: 0.0, m: 0.95, y: 0.95, k: 0.1)
  // highlight-colorConversion-defineSpot

  // highlight-colorConversion-toSrgb
  let cmykCyan = Color.cmyk(c: 1.0, m: 0.0, y: 0.0, k: 0.0, tint: 1.0)
  let cyanAsSrgb = try engine.editor.convertColorToColorSpace(color: cmykCyan, colorSpace: .sRGB)
  print("CMYK cyan as sRGB: \(cyanAsSrgb)")
  // highlight-colorConversion-toSrgb

  // highlight-colorConversion-toCmyk
  let srgbRed = Color.rgba(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
  let redAsCmyk = try engine.editor.convertColorToColorSpace(color: srgbRed, colorSpace: .cmyk)
  print("sRGB red as CMYK: \(redAsCmyk)")
  // highlight-colorConversion-toCmyk

  // highlight-colorConversion-spotConvert
  let spot = Color.spot(name: "Brand Red", tint: 1.0, externalReference: "")
  let spotAsSrgb = try engine.editor.convertColorToColorSpace(color: spot, colorSpace: .sRGB)
  let spotAsCmyk = try engine.editor.convertColorToColorSpace(color: spot, colorSpace: .cmyk)
  print("Spot 'Brand Red' as sRGB: \(spotAsSrgb)")
  print("Spot 'Brand Red' as CMYK: \(spotAsCmyk)")
  // highlight-colorConversion-spotConvert

  // highlight-colorConversion-identify
  let unknown: Color = redAsCmyk
  switch unknown {
  case let .rgba(r, g, b, a):
    print("sRGB: r=\(r), g=\(g), b=\(b), a=\(a)")
  case let .cmyk(c, m, y, k, tint):
    print("CMYK: c=\(c), m=\(m), y=\(y), k=\(k), tint=\(tint)")
  case let .spot(name, tint, externalReference):
    print("Spot: name=\(name), tint=\(tint), ref=\(externalReference)")
  @unknown default:
    print("Unknown color space")
  }

  let space: ColorSpace = unknown.colorSpace
  print("Color space: \(space)")
  // highlight-colorConversion-identify

  // highlight-colorConversion-colorPicker
  // Build display values for a custom color picker. The input would normally
  // come from `engine.block.getColor`; here a literal stands in for a real
  // block color.
  let pickerInput: Color = .cmyk(c: 0.5, m: 0.0, y: 1.0, k: 0.0, tint: 1.0)
  let pickerSrgb = try engine.editor.convertColorToColorSpace(color: pickerInput, colorSpace: .sRGB)
  if case let .rgba(r, g, b, _) = pickerSrgb {
    print("R: \(Int(r * 255)), G: \(Int(g * 255)), B: \(Int(b * 255))")
  }
  // highlight-colorConversion-colorPicker

  // highlight-colorConversion-exportPrep
  // Before PDF export, ensure each color is in CMYK. Skip conversion when it
  // already is.
  let exportInput: Color = .rgba(r: 0.2, g: 0.4, b: 0.9, a: 1.0)
  if case .cmyk = exportInput {
    print("Already CMYK: \(exportInput)")
  } else {
    let cmyk = try engine.editor.convertColorToColorSpace(color: exportInput, colorSpace: .cmyk)
    print("Converted to CMYK: \(cmyk)")
  }
  // highlight-colorConversion-exportPrep
}
