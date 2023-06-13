import IMGLYCore
import Introspect
import SwiftUI

@MainActor
public struct BuildInfo: View {
  public init() {}

  static var info: String? {
    guard let name, let version, let build, let branch, let hash else {
      return nil
    }
    let shortHash = hash.isEmpty ? "" : "-\(hash.prefix(7))"
    return "\(name) \(version)\(shortHash) (\(build))\n\(branch)"
  }

  static var name: String? { Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String }
  static var version: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
  static var build: String? { Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String }
  static var target: String? { Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String }
  static var branch: String? { Bundle.main.infoDictionary?["GitBranch"] as? String }
  static var hash: String? { Bundle.main.infoDictionary?["GitHash"] as? String }

  static var commitURL: URL? {
    guard let hash else {
      return nil
    }
    return URL(string: "\(Secrets.githubRepo)/commit/\(hash)")
  }

  @State private var update = Update.State.loading
  @Environment(\.scenePhase) var scenePhase

  @State private var showSwitchBranchSheet = false

  @ViewBuilder var menu: some View {
    if let commitURL = Self.commitURL {
      Button {
        UIApplication.shared.open(commitURL)
      } label: {
        Label("Open Commit", systemImage: "square.and.arrow.up")
      }
    }
    Button {
      showSwitchBranchSheet = true
    } label: {
      Label("Switch Branch …", systemImage: "shuffle")
    }
  }

  @ViewBuilder func buildInfo(_ info: String) -> some View {
    Menu {
      menu
    } label: {
      Text(info)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)
        .font(.system(size: 10, design: .monospaced))
        .task(id: scenePhase, priority: .background) {
          guard let branch = Self.branch, scenePhase == .active else {
            return
          }
          do {
            let update = try await Update.request(branch: branch)
            if update.build != Self.build {
              self.update = .loaded(update)
            }
          } catch {
            update = .error(error)
            print("Could not update branch '\(branch)':", error.localizedDescription)
          }
        }
    }
    .sheet(isPresented: $showSwitchBranchSheet) {
      SwitchBranchSheet()
    }
  }

  @ViewBuilder var updateButton: some View {
    Group {
      if case let .loaded(update) = update {
        Button {
          UIApplication.shared.open(update.url)
        } label: {
          Label("Update to build \(update.build)", systemImage: "arrow.down.circle")
            .padding([.leading, .trailing], 1)
        }
      } else if case let .error(error) = update, let networkError = error as? NetworkError,
                case let .invalidStatusCode(status) = networkError, status == 403 {
        Button {
          Task {
            // Fix open sheet when menu is open.
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 200)
            showSwitchBranchSheet = true
          }
        } label: {
          Label("Switch deleted branch …", systemImage: "shuffle")
            .padding([.leading, .trailing], 1)
        }
      }
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.capsule)
    .controlSize(.small)
    .textCase(.uppercase)
    .font(.subheadline.weight(.bold))
  }

  public var body: some View {
    if !ProcessInfo.isUITesting, let info = Self.info {
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

@MainActor
private struct SwitchBranchSheet: View {
  @StateObject private var branch = Debouncer(initialValue: "")
  let defaultBranch = "develop"

  @State var state = Update.State.loading

  var canUpdate: Bool {
    if case let .loaded(update) = state {
      return update.build != BuildInfo.build || update.branch != BuildInfo.branch
    } else {
      return false
    }
  }

  @ViewBuilder var switchButton: some View {
    Button(role: .destructive) {
      if case let .loaded(update) = state {
        UIApplication.shared.open(update.url)
      }
    } label: {
      Label("Switch Branch", systemImage: "shuffle")
    }
    .foregroundColor(canUpdate ? .red : .accentColor)
    .disabled(!canUpdate)
  }

  @ViewBuilder var message: some View {
    switch state {
    case .loading:
      Label("Checking for builds...", systemImage: "hourglass.circle.fill")
    case let .loaded(update):
      let message: LocalizedStringKey = canUpdate ?
        "Found latest build \(update.build)." :
        "You are already on the latest build \(update.build) of this branch."
      Label(message, systemImage: "checkmark.circle.fill")
    case .error:
      Label("No builds found.", systemImage: "exclamationmark.circle.fill")
    }
  }

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationView {
      List {
        Section {
          TextField(defaultBranch, text: $branch.value)
            .font(.system(.body, design: .monospaced))
            .keyboardType(.URL)
            .submitLabel(.search)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .introspectTextField {
              $0.clearButtonMode = .whileEditing
            }
            .onReceive(branch.$value) { newValue in
              guard newValue != branch.value else {
                return
              }
              state = .loading
            }
        } header: {
          Text("Branch Name")
        } footer: {
          message.imageScale(.large)
        }
        .task(id: branch.debouncedValue) {
          func getBranch(_ branch: String) -> String {
            branch.isEmpty ? defaultBranch : branch
          }
          let branch = getBranch(branch.debouncedValue)
          do {
            let update = try await Update.request(branch: branch)
            guard branch == getBranch(self.branch.value) else {
              return
            }
            state = .loaded(update)
          } catch is CancellationError {
          } catch {
            guard branch == getBranch(self.branch.value) else {
              return
            }
            state = .error(error)
            print("Could not switch branch '\(branch)':", error.localizedDescription)
          }
        }
        switchButton
      }
      .navigationTitle("Switch Branch")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Label("Cancel", systemImage: "xmark.circle.fill")
              .symbolRenderingMode(.hierarchical)
              .foregroundColor(.secondary)
              .font(.title2)
          }
        }
      }
    }
    .conditionalPresentationDetents([.medium], selection: .constant(.medium))
    .conditionalPresentationDragIndicator(.visible)
  }
}

private enum NetworkError: Swift.Error {
  case invalidURL
  case invalidResponse
  case invalidStatusCode(Int)
}

private struct Update: Equatable {
  let url: URL
  let build: String
  let branch: String

  enum State {
    case loading
    case loaded(Update)
    case error(Swift.Error)
  }

  @MainActor
  private static func versionURL(branch: String) -> URL? {
    guard let target = BuildInfo.target else {
      return nil
    }
    var components = URLComponents()
    components.scheme = "https"
    components.host = Secrets.ciBuildsHost
    components.path = "/" + branch + "/apps/" + target + "/version.json"
    return components.url
  }

  private struct FastlaneVersion: Decodable {
    let latestVersion, updateUrl, plist_url, ipa_url, build_number, bundle_version: String
    let release_notes: String?
  }

  static func request(branch: String) async throws -> Update {
    guard let versionURL = await versionURL(branch: branch) else {
      throw NetworkError.invalidURL
    }
    let response = try await URLSession.get(versionURL)
    try Task.checkCancellation()
    guard let status = (response.1 as? HTTPURLResponse)?.statusCode else {
      throw NetworkError.invalidResponse
    }
    guard (200 ..< 300) ~= status else {
      throw NetworkError.invalidStatusCode(status)
    }
    let data = response.0
    let decoder = JSONDecoder()
    let latest = try decoder.decode(FastlaneVersion.self, from: data)

    guard let url = URL(string: latest.updateUrl) else {
      throw NetworkError.invalidURL
    }
    return Update(url: url, build: latest.build_number, branch: branch)
  }
}

struct BuildInfo_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews
      .buildInfo()
  }
}
