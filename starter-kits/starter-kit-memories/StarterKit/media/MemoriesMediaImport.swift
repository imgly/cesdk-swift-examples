import CoreTransferable
import ImageIO
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// Copies picked photos and videos into the app's temporary folder, so that the engine can read them
/// by file URL without photo library access.
enum MemoriesMediaImport {
  /// Imports `pickerItems` in order, with IDs counting up from `firstID`. Items that fail to load are
  /// skipped.
  static func items(from pickerItems: [PhotosPickerItem], firstID: Int) async -> [MemoriesMediaItem] {
    var items: [MemoriesMediaItem] = []
    for pickerItem in pickerItems {
      let id = firstID + items.count
      if pickerItem.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
        if let movie = try? await pickerItem.loadTransferable(type: MovieFile.self) {
          items.append(MemoriesMediaItem(id: id, url: movie.url, isVideo: true))
        }
      } else if let data = try? await pickerItem.loadTransferable(type: Data.self),
                let url = try? writeImage(data) {
        items.append(MemoriesMediaItem(id: id, url: url, creationDate: captureDate(of: data)))
      }
    }
    return items
  }

  /// Writes JPEG and PNG data as they are, and anything else, such as HEIC, as JPEG. The type comes from
  /// the data, not the picker item: an item can list `public.jpeg` and still load as HEIC.
  private static func writeImage(_ data: Data) throws -> URL {
    let type = CGImageSourceCreateWithData(data as CFData, nil)
      .flatMap(CGImageSourceGetType)
      .flatMap { UTType($0 as String) }
    if let type, type == .jpeg || type == .png, let ext = type.preferredFilenameExtension {
      return try write(data, extension: ext)
    }
    guard let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.9) else {
      throw CocoaError(.fileReadCorruptFile)
    }
    return try write(jpeg, extension: "jpg")
  }

  private static func write(_ data: Data, extension ext: String) throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("memories-\(UUID().uuidString).\(ext)")
    try data.write(to: url)
    return url
  }

  /// The EXIF capture date. EXIF stores local wall-clock time without a zone, so it is read in the
  /// device's zone.
  private static func captureDate(of data: Data) -> Date? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else { return nil }
    let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
    let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
    let value = exif?[kCGImagePropertyExifDateTimeOriginal] ?? exif?[kCGImagePropertyExifDateTimeDigitized]
      ?? tiff?[kCGImagePropertyTIFFDateTime]
    guard let string = value as? String else { return nil }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    return formatter.date(from: string)
  }

  /// A picked video, copied out of the picker's temporary file before that file goes away.
  private struct MovieFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
      FileRepresentation(importedContentType: .movie) { received in
        let ext = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("memories-\(UUID().uuidString).\(ext)")
        try FileManager.default.copyItem(at: received.file, to: url)
        return MovieFile(url: url)
      }
    }
  }
}
