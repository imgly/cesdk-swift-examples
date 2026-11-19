import SwiftUI

/// Covers the editor while the slideshow is built: the picked media flash in a 4 × 4 grid.
struct MemoriesLoadingScreen: View {
  let items: [MemoriesMediaItem]
  @State private var hasEntered = false

  var body: some View {
    ZStack {
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
        ForEach(0 ..< 16, id: \.self) { _ in
          FlashingCell(items: items)
        }
      }
      .padding(32)
      .opacity(hasEntered ? 1 : 0)
      .animation(.easeIn(duration: 0.6), value: hasEntered)

      VStack(spacing: 8) {
        Text("Hold tight")
          .font(.title.bold())
          .opacity(hasEntered ? 1 : 0)
          .animation(.easeIn(duration: 0.6).delay(0.3), value: hasEntered)
        Text("We're magically creating\nmemories for you \(Image(systemName: "sparkles"))")
          .multilineTextAlignment(.center)
          .opacity(hasEntered ? 1 : 0)
          .animation(.easeIn(duration: 0.6).delay(0.6), value: hasEntered)
      }
      .padding(48)
      .background(RadialGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)],
                                 center: .center, startRadius: 0, endRadius: 180))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
    // Keeps taps away from the editor while it loads underneath.
    .contentShape(Rectangle())
    .onAppear { hasEntered = true }
  }

  /// Shows a random item for a moment, hides it, and repeats with another one, each at its own pace.
  private struct FlashingCell: View {
    let items: [MemoriesMediaItem]
    @State private var item: MemoriesMediaItem?
    @State private var isVisible = false

    var body: some View {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(.secondarySystemBackground).opacity(0.3))
        .aspectRatio(1, contentMode: .fit)
        .overlay {
          if let item {
            MemoriesThumbnailView(item: item)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .opacity(isVisible ? 1 : 0)
          }
        }
        .scaleEffect(isVisible ? 0.9 : 1)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .task {
          guard !items.isEmpty else { return }
          isVisible = .random()
          while !Task.isCancelled {
            if isVisible {
              isVisible = false
              try? await Task.sleep(for: .milliseconds(Int.random(in: 300 ... 500)))
            } else {
              item = items.randomElement()
              isVisible = true
              try? await Task.sleep(for: .milliseconds(Int.random(in: 300 ... 400)))
            }
          }
        }
    }
  }
}
