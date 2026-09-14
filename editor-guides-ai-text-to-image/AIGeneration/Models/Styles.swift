import Foundation

/// Output type for generation
public enum OutputType: String, CaseIterable, Codable, Sendable {
  case image = "Image"
  case vector = "Vector"

  var iconName: String {
    switch self {
    case .image: "photo"
    case .vector: "square.on.circle"
    }
  }
}

/// Style options for image generation
public enum ImageStyle: String, CaseIterable, Codable, Sendable {
  // Main styles
  case realisticImage = "Realistic Image"
  case digitalIllustration = "Digital Illustration"

  // Realistic Image substyles
  case blackAndWhite = "Black & White"
  case hardFlash = "Hard Flash"
  case hdr = "HDR"
  case naturalLight = "Natural Light"
  case studioPortrait = "Studio Portrait"
  case enterprise = "Enterprise"
  case motionBlur = "Motion Blur"
  case eveningLight = "Evening Light"
  case fadedNostalgia = "Faded Nostalgia"
  case forestLife = "Forest Life"
  case mysticNaturalism = "Mystic Naturalism"
  case naturalTones = "Natural Tones"
  case organicCalm = "Organic Calm"
  case realLifeGlow = "Real Life Glow"
  case retroRealism = "Retro Realism"
  case retroSnapshot = "Retro Snapshot"
  case urbanDrama = "Urban Drama"
  case villageRealism = "Village Realism"
  case warmFolk = "Warm Folk"

  // Digital Illustration substyles
  case pixelArt = "Pixel Art"
  case handDrawn = "Hand Drawn"
  case grain = "Grain"
  case infantileSketch = "Infantile Sketch"
  case artPoster = "2D Art Poster"
  case handmade3D = "Handmade 3D"
  case handDrawnOutline = "Hand Drawn Outline"
  case engravingColor = "Engraving Color"
  case artPoster2 = "2D Art Poster 2"
  case antiquarian = "Antiquarian"
  case boldFantasy = "Bold Fantasy"
  case childBook = "Child Book"
  case cover = "Cover"
  case crosshatch = "Crosshatch"
  case digitalEngraving = "Digital Engraving"
  case expressionism = "Expressionism"
  case freehandDetails = "Freehand Details"
  case grain20 = "Grain 20"
  case graphicIntensity = "Graphic Intensity"
  case hardComics = "Hard Comics"
  case longShadow = "Long Shadow"
  case modernFolk = "Modern Folk"
  case multicolor = "Multicolor"
  case neonCalm = "Neon Calm"
  case noir = "Noir"
  case nostalgicPastel = "Nostalgic Pastel"
  case outlineDetails = "Outline Details"
  case pastelGradient = "Pastel Gradient"
  case pastelSketch = "Pastel Sketch"
  case popArt = "Pop Art"
  case popRenaissance = "Pop Renaissance"
  case streetArt = "Street Art"
  case tabletSketch = "Tablet Sketch"
  case urbanGlow = "Urban Glow"
  case urbanSketching = "Urban Sketching"
  case vanillaDreams = "Vanilla Dreams"
  case youngAdultBook = "Young Adult Book"
  case youngAdultBook2 = "Young Adult Book 2"

  /// The fal.ai/Recraft style ID
  public var styleId: String {
    switch self {
    case .realisticImage: "realistic_image"
    case .digitalIllustration: "digital_illustration"
    case .blackAndWhite: "realistic_image/b_and_w"
    case .hardFlash: "realistic_image/hard_flash"
    case .hdr: "realistic_image/hdr"
    case .naturalLight: "realistic_image/natural_light"
    case .studioPortrait: "realistic_image/studio_portrait"
    case .enterprise: "realistic_image/enterprise"
    case .motionBlur: "realistic_image/motion_blur"
    case .eveningLight: "realistic_image/evening_light"
    case .fadedNostalgia: "realistic_image/faded_nostalgia"
    case .forestLife: "realistic_image/forest_life"
    case .mysticNaturalism: "realistic_image/mystic_naturalism"
    case .naturalTones: "realistic_image/natural_tones"
    case .organicCalm: "realistic_image/organic_calm"
    case .realLifeGlow: "realistic_image/real_life_glow"
    case .retroRealism: "realistic_image/retro_realism"
    case .retroSnapshot: "realistic_image/retro_snapshot"
    case .urbanDrama: "realistic_image/urban_drama"
    case .villageRealism: "realistic_image/village_realism"
    case .warmFolk: "realistic_image/warm_folk"
    case .pixelArt: "digital_illustration/pixel_art"
    case .handDrawn: "digital_illustration/hand_drawn"
    case .grain: "digital_illustration/grain"
    case .infantileSketch: "digital_illustration/infantile_sketch"
    case .artPoster: "digital_illustration/2d_art_poster"
    case .handmade3D: "digital_illustration/handmade_3d"
    case .handDrawnOutline: "digital_illustration/hand_drawn_outline"
    case .engravingColor: "digital_illustration/engraving_color"
    case .artPoster2: "digital_illustration/2d_art_poster_2"
    case .antiquarian: "digital_illustration/antiquarian"
    case .boldFantasy: "digital_illustration/bold_fantasy"
    case .childBook: "digital_illustration/child_book"
    case .cover: "digital_illustration/cover"
    case .crosshatch: "digital_illustration/crosshatch"
    case .digitalEngraving: "digital_illustration/digital_engraving"
    case .expressionism: "digital_illustration/expressionism"
    case .freehandDetails: "digital_illustration/freehand_details"
    case .grain20: "digital_illustration/grain_20"
    case .graphicIntensity: "digital_illustration/graphic_intensity"
    case .hardComics: "digital_illustration/hard_comics"
    case .longShadow: "digital_illustration/long_shadow"
    case .modernFolk: "digital_illustration/modern_folk"
    case .multicolor: "digital_illustration/multicolor"
    case .neonCalm: "digital_illustration/neon_calm"
    case .noir: "digital_illustration/noir"
    case .nostalgicPastel: "digital_illustration/nostalgic_pastel"
    case .outlineDetails: "digital_illustration/outline_details"
    case .pastelGradient: "digital_illustration/pastel_gradient"
    case .pastelSketch: "digital_illustration/pastel_sketch"
    case .popArt: "digital_illustration/pop_art"
    case .popRenaissance: "digital_illustration/pop_renaissance"
    case .streetArt: "digital_illustration/street_art"
    case .tabletSketch: "digital_illustration/tablet_sketch"
    case .urbanGlow: "digital_illustration/urban_glow"
    case .urbanSketching: "digital_illustration/urban_sketching"
    case .vanillaDreams: "digital_illustration/vanilla_dreams"
    case .youngAdultBook: "digital_illustration/young_adult_book"
    case .youngAdultBook2: "digital_illustration/young_adult_book_2"
    }
  }

  /// Preview image name for the style
  public var previewImageName: String {
    switch self {
    case .blackAndWhite:
      "realistic_image_black_&_white"
    case .handDrawnOutline:
      "digital_illustration_handdrawn_outline"
    case .artPoster2:
      "digital_illustration_2d_artposter_2"
    default:
      styleId.replacingOccurrences(of: "/", with: "_")
    }
  }
}

/// Style options for vector generation
public enum VectorStyle: String, CaseIterable, Codable, Sendable {
  case vectorIllustration = "Vector Illustration"
  case boldStroke = "Bold Stroke"
  case chemistry = "Chemistry"
  case coloredStencil = "Colored Stencil"
  case contourPopArt = "Contour Pop Art"
  case cosmics = "Cosmics"
  case cutout = "Cutout"
  case depressive = "Depressive"
  case editorial = "Editorial"
  case emotionalFlat = "Emotional Flat"
  case infographical = "Infographical"
  case markerOutline = "Marker Outline"
  case mosaic = "Mosaic"
  case naivector = "Naive Vector"
  case roundishFlat = "Roundish Flat"
  case segmentedColors = "Segmented Colors"
  case sharpContrast = "Sharp Contrast"
  case thin = "Thin"
  case vectorPhoto = "Vector Photo"
  case vividShapes = "Vivid Shapes"
  case engraving = "Engraving"
  case lineArt = "Line Art"
  case lineCircuit = "Line Circuit"
  case linocut = "Linocut"

  /// The fal.ai/Recraft style ID
  public var styleId: String {
    switch self {
    case .vectorIllustration: "vector_illustration"
    case .boldStroke: "vector_illustration/bold_stroke"
    case .chemistry: "vector_illustration/chemistry"
    case .coloredStencil: "vector_illustration/colored_stencil"
    case .contourPopArt: "vector_illustration/contour_pop_art"
    case .cosmics: "vector_illustration/cosmics"
    case .cutout: "vector_illustration/cutout"
    case .depressive: "vector_illustration/depressive"
    case .editorial: "vector_illustration/editorial"
    case .emotionalFlat: "vector_illustration/emotional_flat"
    case .infographical: "vector_illustration/infographical"
    case .markerOutline: "vector_illustration/marker_outline"
    case .mosaic: "vector_illustration/mosaic"
    case .naivector: "vector_illustration/naivector"
    case .roundishFlat: "vector_illustration/roundish_flat"
    case .segmentedColors: "vector_illustration/segmented_colors"
    case .sharpContrast: "vector_illustration/sharp_contrast"
    case .thin: "vector_illustration/thin"
    case .vectorPhoto: "vector_illustration/vector_photo"
    case .vividShapes: "vector_illustration/vivid_shapes"
    case .engraving: "vector_illustration/engraving"
    case .lineArt: "vector_illustration/line_art"
    case .lineCircuit: "vector_illustration/line_circuit"
    case .linocut: "vector_illustration/linocut"
    }
  }

  /// Preview image name for the style
  public var previewImageName: String {
    styleId.replacingOccurrences(of: "/", with: "_")
  }
}

/// Format options for generated images
public enum FormatOption: String, CaseIterable, Codable, Sendable {
  case squareHD = "Square HD"
  case square = "Square"
  case portrait43 = "Portrait 4:3"
  case portrait169 = "Portrait 16:9"
  case landscape43 = "Landscape 4:3"
  case landscape169 = "Landscape 16:9"
  case custom = "Custom"

  /// Returns the fal.ai size ID for this format
  public var sizeId: String {
    switch self {
    case .squareHD: "square_hd"
    case .square: "square"
    case .portrait43: "portrait_4_3"
    case .portrait169: "portrait_16_9"
    case .landscape43: "landscape_4_3"
    case .landscape169: "landscape_16_9"
    case .custom: "square_hd"
    }
  }

  /// Short label for compact display
  public var shortLabel: String {
    switch self {
    case .squareHD: "1:1 (Square HD)"
    case .square: "1:1 (Square)"
    case .portrait43: "3:4 (Portrait)"
    case .portrait169: "9:16 (Portrait)"
    case .landscape43: "4:3 (Landscape)"
    case .landscape169: "16:9 (Landscape)"
    case .custom: "Custom"
    }
  }

  /// SF Symbol name for this format
  public var iconName: String {
    switch self {
    case .square, .squareHD: "square"
    case .portrait43, .portrait169: "rectangle.portrait"
    case .landscape43, .landscape169: "rectangle"
    case .custom: "aspectratio"
    }
  }

  public var dimensions: (width: Int, height: Int) {
    switch self {
    case .squareHD: (1024, 1024)
    case .square: (512, 512)
    case .portrait43: (1024, 1365)
    case .portrait169: (1024, 1820)
    case .landscape43: (1365, 1024)
    case .landscape169: (1820, 1024)
    case .custom: (512, 512)
    }
  }

  public var aspectRatio: CGFloat {
    let dims = dimensions
    return CGFloat(dims.width) / CGFloat(dims.height)
  }

  public var aspectRatioText: String {
    switch self {
    case .square, .squareHD: "1:1"
    case .portrait43: "3:4"
    case .portrait169: "9:16"
    case .landscape43: "4:3"
    case .landscape169: "16:9"
    case .custom: "Custom"
    }
  }
}

/// Background options for generated images
public enum BackgroundOption: String, CaseIterable, Codable, Sendable {
  case standard = "Standard"
  case transparent = "Transparent"
}
