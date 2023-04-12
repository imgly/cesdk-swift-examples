import SwiftUI

@MainActor
public struct BuildInfo: View {
  public init() {}

  var info: String? {
    guard let name, let version, let build, let branch, let hash else {
      return nil
    }
    let shortHash = hash.isEmpty ? "" : "-\(hash.prefix(7))"
    return "\(name) \(version)\(shortHash) (\(build))\n\(branch)"
  }

  var name: String? { Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String }
  var version: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
  var build: String? { Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String }
  var target: String? { Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String }
  var branch: String? { Bundle.main.infoDictionary?["GitBranch"] as? String }
  var hash: String? { Bundle.main.infoDictionary?["GitHash"] as? String }

  var versionURL: URL? {
    guard let branch, let target else {
      return nil
    }
    var components = URLComponents()
    components.scheme = "https"
    components.host = Secrets.ciBuildsHost
    components.path = "/" + branch + "/apps/" + target + "/version.json"
    return components.url
  }

  var commitURL: URL? {
    guard let hash else {
      return nil
    }
    return URL(string: "\(Secrets.githubRepo)/commit/\(hash)")
  }

  func checkForUpdate() async throws -> Update? {
    guard let versionURL else {
      throw Error(errorDescription: "Invalid version URL.")
    }
    let data = try await URLSession.get(versionURL).0
    let decoder = JSONDecoder()
    let latest = try decoder.decode(FastlaneVersion.self, from: data)

    if latest.build_number != build {
      guard let url = URL(string: latest.updateUrl) else {
        throw Error(errorDescription: "Invalid update URL.")
      }
      return Update(url: url, build: latest.build_number)
    } else {
      return nil
    }
  }

  struct FastlaneVersion: Decodable {
    let latestVersion, updateUrl, plist_url, ipa_url, build_number, bundle_version: String
    let release_notes: String?
  }

  struct Update: Equatable {
    let url: URL
    let build: String
  }

  @State var update: Update?
  @Environment(\.scenePhase) var scenePhase

  @MainActor @ViewBuilder func buildInfo(_ info: String) -> some View {
    Text(info)
      .onLongPressGesture {
        guard let commitURL else {
          return
        }
        UIApplication.shared.open(commitURL)
      }
      .multilineTextAlignment(.center)
      .font(.system(size: 10, design: .monospaced))
      .task(id: scenePhase, priority: .background) {
        guard scenePhase == .active else {
          return
        }
        do {
          update = try await checkForUpdate()
        } catch {
          print(error.localizedDescription)
        }
      }
  }

  @MainActor @ViewBuilder var updateButton: some View {
    if let update {
      Button {
        UIApplication.shared.open(update.url)
      } label: {
        Label("Update to build \(update.build)", systemImage: "arrow.down.circle")
          .padding([.leading, .trailing], 1)
      }
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.capsule)
      .controlSize(.small)
      .textCase(.uppercase)
      .font(.subheadline.weight(.bold))
    }
  }

  public var body: some View {
    if !ProcessInfo.isUITesting, let info {
      HStack {
        Spacer(minLength: 0)
        VStack {
          buildInfo(info)
          updateButton
        }
        Spacer(minLength: 0)
      }
      .padding()
      .background(.bar)
    }
  }
}
