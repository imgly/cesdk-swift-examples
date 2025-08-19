import Foundation

struct Secrets: Codable {
  let remoteAssetSourceHost: String
  let unsplashHost: String
  let ciBuildsHost: String
  let githubRepo: String
  let licenseKey: String
}

let secrets = Secrets(
  remoteAssetSourceHost: "",
  unsplashHost: "",
  ciBuildsHost: "",
  githubRepo: "",
  licenseKey: "",
)
