import Foundation

struct Secrets: Codable {
  let unsplashHost: String
  let ciBuildsHost: String
  let githubRepo: String
  let licenseKey: String
}

let secrets = Secrets(
  unsplashHost: "",
  ciBuildsHost: "",
  githubRepo: "",
  licenseKey: ""
)
