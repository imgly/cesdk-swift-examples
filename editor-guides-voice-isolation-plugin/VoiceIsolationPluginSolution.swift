// highlight-voiceIsolationPlugin-imports
import IMGLYEditor
import IMGLYEngine
import IMGLYPluginVoiceIsolation

// highlight-voiceIsolationPlugin-imports
import SwiftUI

struct VoiceIsolationPluginSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>",
                                baseURL: secrets.baseURL)

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration { builder in
          // Demo scaffolding, not part of the lesson: open a sample video and select its clip, so the inspector bar
          // shows the "Isolate Voice" button.
          builder.onCreate { engine, _ in
            try await VideoEditorConfiguration.defaultOnCreate(createScene: { engine in
              let basePath = try engine.editor.getSettingString("basePath")
              guard let videoURL = URL(string: "\(basePath)/ly.img.video/videos/pexels-kampus-production-8154913.mp4")
              else { return }
              try await engine.scene.create(fromVideo: videoURL)
            })(engine)
          }
          builder.onLoaded { context, existing in
            try await existing()
            let engine = context.engine
            if let clip = try engine.block.find(byType: .graphic)
              .first(where: { VoiceIsolationPlugin.canIsolateVoice(of: $0, engine: engine) }) {
              try engine.block.setSelected(clip, selected: true)
            }
          }
        }
        VoiceIsolationPlugin()
      }
  }

  // The lesson code shown in the documentation. The runtime demo above opens a sample clip and selects it; the
  // rendered snippet keeps the minimal integration developers add to their own editor.
  var editor: some View {
    // highlight-voiceIsolationPlugin-basicSetup
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        VoiceIsolationPlugin()
      }
    // highlight-voiceIsolationPlugin-basicSetup
  }
}

// MARK: - Configuration

struct VoiceIsolationConfigurationSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")
  @State private var errorMessage: String?

  var body: some View {
    // highlight-voiceIsolationPlugin-configuration
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        VoiceIsolationPlugin(
          configuration: IMGLYVoiceIsolationConfiguration(
            // The default model location. Replace it with the folder on your server or in your app.
            modelBaseURL: IMGLYVoiceIsolationConfiguration.defaultModelBaseURL,
            loadMode: .lazy,
          ),
          onError: { error in
            errorMessage = error.localizedDescription
          },
          inspectorBarModifier: { items, button in
            items.addLast { button }
          },
        )
      }
      .alert("Voice Isolation Error", isPresented: .constant(errorMessage != nil)) {
        Button("OK") { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "")
      }
    // highlight-voiceIsolationPlugin-configuration
  }
}

// MARK: - Clean Clips from Code

struct VoiceIsolationBlockCallSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>",
                                baseURL: secrets.baseURL)

  var body: some View {
    // highlight-voiceIsolationPlugin-blockCall
    let voiceIsolation = VoiceIsolationPlugin()
    return Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration { builder in
          builder.onCreate { engine, _ in
            try await VideoEditorConfiguration.defaultOnCreate(createScene: { engine in
              let basePath = try engine.editor.getSettingString("basePath")
              guard let videoURL = URL(string: "\(basePath)/ly.img.video/videos/pexels-kampus-production-8154913.mp4")
              else { return }
              try await engine.scene.create(fromVideo: videoURL)
            })(engine)
            guard let clip = try engine.block.find(byType: .graphic)
              .first(where: { VoiceIsolationPlugin.canIsolateVoice(of: $0, engine: engine) }) else { return }
            do {
              let cleanedClip = try await voiceIsolation.isolateVoice(of: clip, engine: engine)
              print("Cleaned audio clip \(cleanedClip).")
            } catch {
              print("Could not isolate the voice: \(error.localizedDescription)")
            }
          }
        }
        voiceIsolation
      }
    // highlight-voiceIsolationPlugin-blockCall
  }
}

// MARK: - Custom Provider

// highlight-voiceIsolationPlugin-customProvider
struct CustomVoiceIsolationProvider: VoiceIsolationProvider {
  func prewarm() async throws {
    // Download or load your model here.
  }

  func isolateVoice(from input: URL, to output: URL) async throws {
    // Replace this copy with your model or service. Write a WAV file with the format and length of `input`.
    try FileManager.default.copyItem(at: input, to: output)
  }
}

struct CustomVoiceIsolationConfiguration: VoiceIsolationConfiguration {
  var provider: any VoiceIsolationProvider = CustomVoiceIsolationProvider()
}

// highlight-voiceIsolationPlugin-customProvider

struct VoiceIsolationCustomProviderSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        // highlight-voiceIsolationPlugin-customProviderSetup
        VoiceIsolationPlugin(configuration: CustomVoiceIsolationConfiguration())
        // highlight-voiceIsolationPlugin-customProviderSetup
      }
  }
}

// MARK: - Chained Provider

// highlight-voiceIsolationPlugin-chainedProvider
struct ChainedVoiceIsolationProvider: VoiceIsolationProvider {
  let imglyProvider = IMGLYVoiceIsolationProvider()

  func prewarm() async throws {
    try await imglyProvider.prewarm()
  }

  func isolateVoice(from input: URL, to output: URL) async throws {
    let firstPass = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("wav")
    defer { try? FileManager.default.removeItem(at: firstPass) }
    // Replace this copy with your model. Write a WAV file with the format and length of `input`.
    try FileManager.default.copyItem(at: input, to: firstPass)
    try await imglyProvider.isolateVoice(from: firstPass, to: output)
  }
}

// highlight-voiceIsolationPlugin-chainedProvider

struct VoiceIsolationChainedProviderSolution: View {
  let settings = EngineSettings(license: secrets.licenseKey,
                                userID: "<your unique user id>")

  var body: some View {
    Editor(settings)
      .imgly.configuration {
        VideoEditorConfiguration()
        // highlight-voiceIsolationPlugin-chainedProviderSetup
        VoiceIsolationPlugin(configuration: CustomVoiceIsolationConfiguration(
          provider: ChainedVoiceIsolationProvider(),
        ))
        // highlight-voiceIsolationPlugin-chainedProviderSetup
      }
  }
}
