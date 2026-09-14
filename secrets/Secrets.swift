import Foundation

struct Secrets: Codable {
  let remoteAssetSourceHost: String
  let unsplashHost: String
  let ciBuildsHost: String
  let githubRepo: String
  let licenseKey: String
  let falAIProxyURL: String

  @MainActor var baseURL: URL? { nil }
}

let secrets = Secrets(
  remoteAssetSourceHost: "",
  unsplashHost: "",
  ciBuildsHost: "",
  githubRepo: "",
  licenseKey: "",
  falAIProxyURL: "",
)
