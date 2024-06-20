import IMGLYPhotoEditor
import SwiftUI

struct CustomPhotoEditor: View {
  private let formats: PhotoSelection.Formats = [
    ("original", "Original", nil),
    ("1_1", "Square · 1:1", .init(width: 1080, height: 1080)),
    ("9_16", "Full HD · 9:16", .init(width: 1080, height: 1920)),
    ("16_9", "Full HD · 16:9", .init(width: 1920, height: 1080)),
    ("2_3", "Photo · 2:3", .init(width: 1080, height: 1620)),
    ("3_2", "Photo · 3:2", .init(width: 1620, height: 1080)),
    ("3_4", "Photo · 3:4", .init(width: 1080, height: 1440)),
    ("4_3", "Photo · 4:3", .init(width: 1440, height: 1080))
  ]

  var body: some View {
    PhotoSelection(formats: formats) { url, size in
      PhotoEditor(settings)
        .imgly.onCreate { engine in
          try await OnCreate.loadImage(from: url, size: size)(engine)
        }
    }
  }
}
