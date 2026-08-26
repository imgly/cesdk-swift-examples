// highlight-autoCaptionsPlugin-imports
import IMGLYEditor
import IMGLYEngine
import IMGLYPluginAutoCaptions

// highlight-autoCaptionsPlugin-imports
import SwiftUI

struct AutoCaptionsPluginSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration { builder in
          // Demo scaffolding — not part of the lesson: open a sample video so Generate
          // Automatically has audible content to transcribe.
          builder.onCreate { engine, _ in
            try await engine.scene.create(fromVideo: Self.sampleVideoURL)
          }
        }
        AutoCaptionsPlugin(provider: GatewayTranscriptionProvider(apiKey: secrets.gatewayApiKey))
      }
  }

  // The lesson code shown in the documentation. The runtime demo above adds a sample
  // clip via `onCreate` so the showcase opens with footage to transcribe; the rendered
  // snippet keeps the minimal integration developers add to their own editor.
  var editor: some View {
    // highlight-autoCaptionsPlugin-basicSetup
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        AutoCaptionsPlugin(provider: GatewayTranscriptionProvider(apiKey: "sk_…"))
      }
    // highlight-autoCaptionsPlugin-basicSetup
  }

  /// The video the demo opens with, so Generate Automatically has speech to transcribe.
  private static let sampleVideoURL: URL = {
    let baseURL = secrets.baseURL
      ?? URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.81.1/assets")!
    return baseURL.appendingPathComponent("ly.img.video/videos/pexels-kampus-production-8154913.mp4")
  }()
}

// MARK: - Transcription Options

struct AutoCaptionsOptionsSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-autoCaptionsPlugin-transcriptionOptions
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        AutoCaptionsPlugin(
          provider: GatewayTranscriptionProvider(apiKey: "sk_…"),
          options: TranscriptionOptions(
            language: "en",
            maxLineLength: 30,
            maxLines: 2,
          ),
        )
      }
    // highlight-autoCaptionsPlugin-transcriptionOptions
  }
}

// MARK: - Custom Transcription Provider

// highlight-autoCaptionsPlugin-customProvider
/// A minimal custom provider: send the audio to any speech-to-text service and
/// return SRT text.
struct CustomTranscriptionProvider: TranscriptionProvider {
  let name = "My Speech-to-Text Service"

  func transcribe(audio: URL, mimeType: String, options: TranscriptionOptions) async throws -> String {
    var request = URLRequest(url: URL(string: "https://example.com/transcribe")!)
    request.httpMethod = "POST"
    request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
    if let language = options.language {
      request.setValue(language, forHTTPHeaderField: "Accept-Language")
    }
    // Upload from the file so a long recording streams out instead of being read
    // into memory.
    let (data, _) = try await URLSession.shared.upload(for: request, fromFile: audio)
    // Convert your service's response to SRT here; return an empty string when
    // no speech was detected.
    guard let srt = String(bytes: data, encoding: .utf8) else {
      throw URLError(.cannotDecodeContentData)
    }
    return srt
  }
}

// highlight-autoCaptionsPlugin-customProvider

struct AutoCaptionsCustomProviderSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-autoCaptionsPlugin-useCustomProvider
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        AutoCaptionsPlugin(provider: CustomTranscriptionProvider())
      }
    // highlight-autoCaptionsPlugin-useCustomProvider
  }
}

// MARK: - Full Custom Generation

struct AutoCaptionsGenerationHookSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    // highlight-autoCaptionsPlugin-generationCallback
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration { builder in
          builder.captionsGeneration { engine in
            // Replace this with your own pipeline: transcribe the scene's audible content
            // and serialize the cues as SRT or VTT, timed relative to the page timeline.
            let srt = try await Self.transcribeScene(engine)
            // Returning `nil` shows the dedicated "No speech was detected" alert; any
            // error you throw shows the generic failure alert.
            guard !srt.isEmpty else {
              return nil
            }
            let file = FileManager.default.temporaryDirectory
              .appendingPathComponent(UUID().uuidString)
              .appendingPathExtension("srt")
            try srt.write(to: file, atomically: true, encoding: .utf8)
            return file
          }
        }
      }
    // highlight-autoCaptionsPlugin-generationCallback
  }

  /// Stand-in for a real transcription pipeline. Returns SRT text, or an empty string when
  /// the scene has no speech.
  private static func transcribeScene(_: Engine) async throws -> String {
    """
    1
    00:00:00,000 --> 00:00:03,000
    Captions from a custom pipeline
    """
  }
}

#Preview {
  AutoCaptionsPluginSolution()
}
