import IMGLYEngine
import os.log
import SwiftUI

// MARK: - Models & Data Source

struct Record: Codable, Hashable, Identifiable {
  var id: String
  var variables: [String: String]
  var outputFileName: String
  /// Optional mapping of a block's name in the template to a bundled image filename.
  var images: [String: String]?
}

enum DataSource {
  static func loadRecords() -> [Record] {
    guard
      let url = Bundle.main.url(forResource: "records", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode([Record].self, from: data)
    else {
      return []
    }
    return decoded
  }
}

// MARK: - Template & Output Paths

enum Template {
  /// Assumes "Template.cearchive" is added to Copy Bundle Resources.
  static var archiveURL: URL {
    guard let url = Bundle.main.url(forResource: "Template", withExtension: "cearchive") else {
      fatalError("Missing Template.cearchive in bundle")
    }
    return url
  }
}

enum Output {
  static func documentsURL(fileName: String, ext: String = "jpg") -> URL {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return dir.appendingPathComponent("\(fileName).\(ext)")
  }
}

// MARK: - Engine Helpers

enum EngineFactory {
  static func make() async throws -> Engine {
    // New initialization form: no EngineSettings
    let engine = try await Engine(license: secrets.licenseKey)
    return engine
  }
}

@MainActor
func applyVariables(_ engine: Engine, values: [String: String]) throws {
  // Variables are (key: String, value: String)
  for (key, value) in values {
    try engine.variable.set(key: key, value: value)
  }
}

@MainActor
func replaceNamedImage(_ engine: Engine, blockName: String, bundledFileName: String) throws {
  guard let fileURL = Bundle.main.url(forResource: bundledFileName, withExtension: nil) else { return }
  if let block = engine.block.find(byName: blockName).first {
    // Update the block's image fill via its fileURI
    let fill = try engine.block.getFill(block)
    try engine.block.setString(fill, property: "fill/image/fileURI", value: fileURL.absoluteString)
    try engine.block.setFill(block, fill: fill)
  }
}

// MARK: - Export

enum Exporter {
  /// Export the given scene/page block as a JPEG image using ExportOptions.
  @MainActor
  static func exportJPEG(_ engine: Engine, sceneOrPage: DesignBlockID, to url: URL, quality: Float = 0.9) async throws {
    let options = ExportOptions(jpegQuality: quality)
    let exportedData = try await engine.block.export(sceneOrPage, mimeType: .jpeg, options: options)
    try exportedData.write(to: url)
  }
}

// MARK: - Preflight

enum Preflight {
  static func validate(templateURL: URL, records: [Record]) throws {
    guard FileManager.default.fileExists(atPath: templateURL.path) else {
      throw NSError(domain: "Batch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Template archive missing"])
    }
    guard !records.isEmpty else {
      throw NSError(domain: "Batch", code: 2, userInfo: [NSLocalizedDescriptionKey: "No records to process"])
    }
    // Optional: ensure all referenced images exist
    for r in records {
      if let imgs = r.images {
        for name in imgs.values where Bundle.main.url(forResource: name, withExtension: nil) == nil {
          throw NSError(
            domain: "Batch",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Missing bundled image: \(name)"],
          )
        }
      }
    }
  }
}

// MARK: - Batch Functions

@MainActor
func processRecord(_ record: Record) async throws -> URL {
  let engine = try await EngineFactory.make()

  // Load the template archive.
  // loadArchive returns a block ID for the loaded scene root.
  // We'll use `.scene.get()` so we don't need to save the reference
  let scene = try await engine.scene.loadArchive(from: Template.archiveURL)

  // Apply variables
  try applyVariables(engine, values: record.variables)

  // Optionally replace named images
  if let imgs = record.images {
    for (blockName, fileName) in imgs {
      try replaceNamedImage(engine, blockName: blockName, bundledFileName: fileName)
    }
  }

  let outURL = Output.documentsURL(fileName: record.outputFileName, ext: "jpg")
  try await Exporter.exportJPEG(engine, sceneOrPage: scene, to: outURL, quality: 0.9)

  return outURL
}

@MainActor
func runBatchSequential(
  records: [Record],
  onProgress: @escaping (Int, Int) -> Void,
  onResult: @escaping (Record, URL) -> Void,
) async {
  for (index, record) in records.enumerated() {
    do {
      let url = try await processRecord(record)
      onResult(record, url)
    } catch {
      print("❌ \(record.id): \(error)")
    }
    onProgress(index + 1, records.count)
  }
}

// MARK: - SwiftUI UI

@MainActor
final class BatchViewModel: ObservableObject {
  @Published var progress: String = "Idle"
  @Published var outputs: [URL] = []

  private let log = Logger(subsystem: "com.example.batch", category: "automation")

  func run() {
    outputs.removeAll()
    let records = DataSource.loadRecords()
    do { try Preflight.validate(templateURL: Template.archiveURL, records: records) } catch {
      progress = "Preflight failed: \(error.localizedDescription)"
      return
    }
    progress = "Starting… 0 / \(records.count)"

    Task {
      await runBatchSequential(
        records: records,
        onProgress: { [weak self] done, total in
          self?.progress = "Processed \(done) / \(total)"
        },
        onResult: { [weak self] _, url in
          self?.outputs.append(url)
          self?.log.info("Exported: \(url.lastPathComponent, privacy: .public)")
        },
      )
      self.progress += " — Done"
    }
  }
}

struct BatchDemoView: View {
  @StateObject private var vm = BatchViewModel()

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        Text(vm.progress).font(.system(.callout, design: .monospaced))
        Button("Run Batch") { vm.run() }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color.accentColor)
          .foregroundColor(.white)
          .cornerRadius(8)

        List(vm.outputs, id: \.self) { url in
          VStack(alignment: .leading, spacing: 2) {
            Text(url.lastPathComponent).font(.subheadline).bold()
            Text(url.path).font(.caption2).foregroundColor(.secondary).lineLimit(2)
          }
        }
      }
      .padding()
      .navigationTitle("CE.SDK Batch Demo")
    }
  }
}

#Preview {
  BatchDemoView()
}
