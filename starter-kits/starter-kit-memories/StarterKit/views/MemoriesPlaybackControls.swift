import SwiftUI

/// Volume, restart, play and loop, and the fullscreen preview, under the timeline strip.
struct MemoriesPlaybackControls: View {
  @ObservedObject var model: MemoriesModel
  let onVolume: () -> Void

  var body: some View {
    HStack {
      Button(action: onVolume) {
        Image(systemName: "speaker.wave.2.fill")
      }
      .accessibilityLabel("Volume")
      Spacer()
      Button { model.restart() } label: {
        Image(systemName: "backward.end.fill")
      }
      .accessibilityLabel("Restart")
      Button { model.setPlaying(!model.isPlaying) } label: {
        Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
          .font(.title)
          .frame(width: 56)
      }
      .accessibilityLabel(model.isPlaying ? "Pause" : "Play")
      Button { model.toggleLoop() } label: {
        Image(systemName: "repeat")
          .foregroundStyle(model.isLooping ? Color.accentColor : .primary)
      }
      .accessibilityLabel(model.isLooping ? "Disable loop" : "Enable loop")
      Spacer()
      Button { model.enterPreview() } label: {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
      }
      .accessibilityLabel("Fullscreen")
    }
    .font(.title3)
    .foregroundStyle(.primary)
    .buttonStyle(.plain)
    .padding(.horizontal, 20)
    .frame(height: 48)
  }
}

/// The controls over the fullscreen preview. A tap anywhere else returns to the editor.
struct MemoriesFullscreenControls: View {
  @ObservedObject var model: MemoriesModel

  var body: some View {
    Color.clear
      .contentShape(Rectangle())
      .onTapGesture { model.exitPreview() }
      .overlay(alignment: .bottom) {
        HStack(spacing: 16) {
          Button { model.setPlaying(!model.isPlaying) } label: {
            Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
              .font(.title2)
              .frame(width: 48, height: 48)
              .background(.black.opacity(0.3), in: Circle())
          }
          .accessibilityLabel(model.isPlaying ? "Pause" : "Play")
          Slider(value: Binding(get: { model.playbackTime }, set: { model.seek(to: $0) }),
                 in: 0 ... max(model.duration, 0.1))
            .tint(.white)
          Text("\(Self.format(model.playbackTime)) / \(Self.format(model.duration))")
            .font(.caption.monospacedDigit())
        }
        .foregroundStyle(.white)
        .padding()
        .background(LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
          .ignoresSafeArea())
      }
  }

  private static func format(_ seconds: Double) -> String {
    let total = max(Int(seconds), 0)
    return String(format: "%02d:%02d", total / 60, total % 60)
  }
}
