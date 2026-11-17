import Foundation

// MARK: - Moderation Service

/// A service that checks a video, an image or a string of text for policy violations.
///
/// Implement this protocol to connect your own moderation backend (e.g. AWS
/// Rekognition, Hive, or a custom service) instead of the default
/// ``GatewayVideoModerationService``.
public protocol VideoModerationService: Sendable {
  /// Checks one video, image or text and returns its frames.
  ///
  /// - Parameter content: The video, image or text to check.
  /// - Returns: For a video, the sampled frames of the whole source file, each with the
  ///   results for every category the service scored. The scanner keeps only the frames
  ///   inside the part of a clip that plays, so return frames for the whole file. For an
  ///   image or a text, a single frame at position `0`. Return only categories you
  ///   actually scored: a category nobody scored is unknown, not clean.
  /// - Important: Never return an empty array to mean "nothing was detected" — throw
  ///   instead. The scanner treats an empty result as a block it failed to check, so
  ///   returning one withholds certification rather than granting it.
  func check(_ content: VideoModerationContent) async throws -> [VideoModerationFrame]

  /// Whether this service can check the given content.
  ///
  /// The scanner asks before sending anything, and reports the blocks it answers
  /// `false` for as unchecked rather than clean. The default accepts remote
  /// `http`/`https` videos and images — a service that fetches files server-side cannot
  /// reach a file on the device, so override it if yours can — and any text that is
  /// not only whitespace.
  func canCheck(_ content: VideoModerationContent) -> Bool
}

public extension VideoModerationService {
  func canCheck(_ content: VideoModerationContent) -> Bool {
    switch content {
    case let .video(url), let .image(url):
      url.scheme == "https" || url.scheme == "http"
    case let .text(text):
      !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }
}

// MARK: - Gateway Moderation Service

/// The default ``VideoModerationService``: runs the `imgly/detection` model through
/// the IMG.LY AI Gateway (`gateway.img.ly`).
///
/// The gateway handles provider routing, credentials and billing, so you only
/// supply an IMG.LY API key (`sk_…`) from the IMG.LY Dashboard — no separate
/// moderation provider account and no proxy of your own.
///
/// For a video, the gateway samples a frame every two seconds and scores each one, so
/// a longer video costs more credits than a short one. Text is sent inline in the
/// request body and needs no upload.
///
/// Videos and images that live on the device — anything added from the photo roll,
/// the camera or an upload source — are uploaded to the gateway so they can be checked
/// too. User-supplied content is the most likely to violate a policy, so leaving it
/// unchecked would be the wrong default. It does mean the user's files leave the
/// device: say so in your privacy policy. If that is not acceptable, initialize the
/// service with `uploadsLocalFiles: false` — local videos and images are then reported
/// as unchecked, which withholds certification instead of passing them silently.
///
/// - Important: An API key shipped inside an app binary can be extracted. Keep
///   it out of source control, and for production consider calling the gateway
///   from your own backend so the key never reaches the client — implement
///   ``VideoModerationService`` against that backend and swap it in.
public actor GatewayVideoModerationService: VideoModerationService {
  /// A content category reported by the detection model.
  private struct Category: Sendable {
    /// The score keys this category covers. Some categories span more than one
    /// provider model — the category is reported at the highest confidence among
    /// the keys the model actually returned.
    let keys: [String]
    let name: String
    let description: String
  }

  /// The categories `imgly/detection` scores for an image. A video frame is scored like
  /// an image. Order defines the order shown in the results panel.
  private static let imageCategories: [Category] = [
    Category(
      keys: ["weapon"],
      name: "Weapons",
      description: "Handguns, rifles, machine guns, threatening knives...",
    ),
    Category(
      keys: ["alcohol"],
      name: "Alcohol",
      description: "Wine, beer, cocktails, champagne...",
    ),
    Category(
      // `recreational_drug` covers cannabis and street drugs; `medical` covers pills,
      // blisters and syringes. Both belong under one user-facing "Drugs" heading.
      keys: ["recreational_drug", "medical"],
      name: "Drugs",
      description: "Cannabis, syringes, glass pipes, bongs, pills...",
    ),
    Category(
      keys: ["nudity"],
      name: "Nudity",
      description: "Raw or partial nudity, sexual acts, and suggestive content.",
    ),
    Category(
      keys: ["offensive"],
      name: "Offensive symbols",
      description: "Nazi symbols, swastikas, confederate flags, offensive gestures...",
    ),
    Category(
      keys: ["gore"],
      name: "Gore",
      description: "Blood, wounds, serious injuries, corpses, skulls...",
    ),
  ]

  /// The text categories `imgly/detection` scores.
  ///
  /// These overlap far more than the image ones: an insulting sentence is usually
  /// scored as toxic too, so a single text block commonly trips several at once.
  private static let textCategories: [Category] = [
    Category(
      keys: ["toxic"],
      name: "Toxic Language",
      description: "Language likely to make someone leave the conversation.",
    ),
    Category(
      keys: ["insulting"],
      name: "Insulting Language",
      description: "Insults, name-calling, and demeaning remarks.",
    ),
    Category(
      keys: ["discriminatory"],
      name: "Discriminatory Language",
      description: "Language that demeans a group or protected characteristic.",
    ),
    Category(
      keys: ["violent"],
      name: "Violent Language",
      description: "Threats of violence and calls to harm someone.",
    ),
    Category(
      keys: ["sexual"],
      name: "Sexual Language",
      description: "Sexually explicit or suggestive wording.",
    ),
    Category(
      // Hyphenated, so it must match verbatim rather than through the version
      // suffix fallback below — which would otherwise reduce it to "self".
      keys: ["self-harm"],
      name: "Self-Harm",
      description: "References to suicide, self-injury, or eating disorders.",
    ),
  ]

  /// The highest confidence among the keys a category covers, or `nil` when the
  /// model returned none of them.
  ///
  /// Provider models can carry a version suffix (`nudity-2.1`, `gore-2.0`), so keys
  /// are matched on the segment before the first `-` as well as verbatim. That way a
  /// provider version bump does not silently drop a category.
  private static func score(for category: Category, in scores: [String: Double]) -> Double? {
    // An exact match always wins. Only fall back to the version-suffix rule when no
    // key matched verbatim, so a hyphenated category name such as `self-harm` is
    // never reduced to `self` and mistaken for a different category.
    let exact = scores.filter { category.keys.contains($0.key) }.values.max()
    if let exact {
      return exact
    }

    return scores
      .filter { entry in
        let base = entry.key.split(separator: "-", maxSplits: 1).first.map(String.init) ?? entry.key
        return category.keys.contains(base)
      }
      .values
      .max()
  }

  private let client: GatewayDetectionClient
  private let thresholds: VideoModerationThresholds

  /// Whether videos and images stored on the device may be uploaded to the gateway.
  ///
  /// Immutable and `Sendable`, so ``canCheck(_:)`` can read it without actor
  /// isolation.
  private let uploadsLocalFiles: Bool

  /// Caches results keyed by content. A video request costs far more than an image, and
  /// a trim or a move only changes which frames count, so a file is sent once.
  private var cache: [VideoModerationContent: [VideoModerationFrame]] = [:]

  /// Creates the service.
  /// - Parameters:
  ///   - apiKey: An IMG.LY Gateway API key (`sk_…`), from the IMG.LY Dashboard.
  ///   - gatewayURL: The gateway base URL.
  ///   - thresholds: Maps confidence scores to severities. See ``VideoModerationThresholds``.
  ///   - uploadsLocalFiles: Whether videos and images stored on the device may be
  ///     uploaded to the gateway to be checked. Pass `false` to keep the user's own
  ///     files on the device; they are then reported as unchecked, which blocks export
  ///     rather than passing them silently.
  ///   - urlSession: The session used for the request. Injectable for testing.
  public init(
    apiKey: String,
    gatewayURL: URL = URL(string: "https://gateway.img.ly")!,
    thresholds: VideoModerationThresholds = .moderate,
    uploadsLocalFiles: Bool = true,
    urlSession: URLSession = .shared,
  ) {
    client = GatewayDetectionClient(apiKey: apiKey, gatewayURL: gatewayURL, urlSession: urlSession)
    self.thresholds = thresholds
    self.uploadsLocalFiles = uploadsLocalFiles
  }

  /// Accepts remote URLs, and local files that still exist and are readable — those
  /// are uploaded before being checked. A file the system has since evicted from the
  /// cache directory answers `false` here, so it is reported as unchecked instead of
  /// failing the whole run.
  ///
  /// Local files are declined outright when the service was created with
  /// `uploadsLocalFiles: false`.
  public nonisolated func canCheck(_ content: VideoModerationContent) -> Bool {
    switch content {
    case let .video(url), let .image(url):
      if url.scheme == "https" || url.scheme == "http" {
        return true
      }
      guard uploadsLocalFiles, url.isFileURL else { return false }
      return FileManager.default.isReadableFile(atPath: url.path)
    case let .text(text):
      return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }

  public func check(_ content: VideoModerationContent) async throws -> [VideoModerationFrame] {
    if let cached = cache[content] {
      return cached
    }

    // A local file has to reach the gateway before the model can look at it. The result
    // cache is keyed on the original content, so an unchanged file is neither
    // re-uploaded nor re-checked on a second run.
    let results: [VideoModerationFrame]
    switch content {
    case let .video(url):
      let completed = try await client.detect(videoURL: url.isFileURL ? client.upload(url) : url)
      // The gateway also reports its own "safe" flag and the highest score per category
      // over the whole file. The kit ignores both and maps the scores of each frame, so
      // that frames the user trimmed away do not flag the clip.
      let frames = try JSONDecoder().decode(DetectionResponse.self, from: completed).output.first?.data.frames
      guard let frames, !frames.isEmpty else {
        throw VideoModerationServiceError.unexpectedResponse
      }
      results = frames.map { frame in
        VideoModerationFrame(position: frame.position / 1000, checks: checks(Self.imageCategories, in: frame.scores))
      }
    case let .image(url):
      let completed = try await client.detect(imageURL: url.isFileURL ? client.upload(url) : url)
      results = try [VideoModerationFrame(position: 0, checks: checks(Self.imageCategories, in: scores(of: completed)))]
    case let .text(text):
      let completed = try await client.detect(text: text)
      results = try [VideoModerationFrame(position: 0, checks: checks(Self.textCategories, in: scores(of: completed)))]
    }
    guard results.contains(where: { !$0.checks.isEmpty }) else {
      throw VideoModerationServiceError.unexpectedResponse
    }

    cache[content] = results
    return results
  }

  /// The scores of a single image or text, from the first output entry.
  private func scores(of completed: Data) throws -> [String: Double] {
    guard let scores = try JSONDecoder().decode(DetectionResponse.self, from: completed).output.first?.data.scores
    else {
      throw VideoModerationServiceError.unexpectedResponse
    }
    return scores
  }

  /// Maps scores to results. Reports only the categories the model actually scored: a
  /// category it omits is unknown, not clean — listing it as a passing check would be a
  /// false all-clear. A key no category covers is still reported, named from its id, so
  /// a category the model adds later is not dropped.
  private func checks(_ categories: [Category], in scores: [String: Double]) -> [VideoModerationCheckResult] {
    let known = categories.compactMap { category -> VideoModerationCheckResult? in
      guard let score = Self.score(for: category, in: scores) else { return nil }
      return VideoModerationCheckResult(
        name: category.name,
        description: category.description,
        state: thresholds.state(for: score),
      )
    }
    let coveredKeys = Set((Self.imageCategories + Self.textCategories).flatMap(\.keys))
    let unknown = scores
      .filter { key, _ in
        let base = key.split(separator: "-", maxSplits: 1).first.map(String.init) ?? key
        return !coveredKeys.contains(key) && !coveredKeys.contains(base)
      }
      .sorted { $0.key < $1.key }
      .map { key, score in
        VideoModerationCheckResult(
          name: key.split(separator: "_").map(\.capitalized).joined(separator: " "),
          description: "Reported by the moderation service.",
          state: thresholds.state(for: score),
        )
      }
    return known + unknown
  }
}

// MARK: - Gateway Client

/// A minimal `URLSession` client for the `imgly/detection` model on the IMG.LY AI
/// Gateway: `POST /v1/responses` with a Bearer `sk_…` key, reading the result off
/// the SSE stream.
///
/// Kept separate from the actor so the streaming read stays entirely within one
/// non-isolated context — `URLSession.AsyncBytes` is not `Sendable` and must not
/// cross an actor boundary.
private struct GatewayDetectionClient: Sendable {
  let apiKey: String
  let gatewayURL: URL
  let urlSession: URLSession

  /// The content-detection model served by the gateway.
  private static let model = "imgly/detection"

  /// The gateway samples the whole video before it answers, so allow for long clips.
  private static let requestTimeout: TimeInterval = 120

  /// Uploads a local file and returns the URL the gateway can fetch it from.
  ///
  /// A presigned upload URL is requested first, then the file is PUT to it directly
  /// with no auth header. `upload(for:fromFile:)` streams the body off disk, so a
  /// long video or a full-resolution photo is never held in memory.
  func upload(_ file: URL) async throws -> URL {
    guard !apiKey.isEmpty else {
      throw VideoModerationServiceError.missingAPIKey
    }

    let contentType = Self.contentType(for: file)
    var request = authorizedRequest(path: "v1/uploads")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: ["content_type": contentType])

    let (metadataData, response) = try await urlSession.data(for: request)
    try Self.validate(response, body: metadataData)
    let metadata = try JSONDecoder().decode(UploadMetadata.self, from: metadataData)

    guard let uploadURL = URL(string: metadata.uploadURL) else {
      throw VideoModerationServiceError.unexpectedResponse
    }
    var put = URLRequest(url: uploadURL, timeoutInterval: Self.requestTimeout)
    put.httpMethod = "PUT"
    put.setValue(contentType, forHTTPHeaderField: "Content-Type")
    let (body, putResponse) = try await urlSession.upload(for: put, fromFile: file)
    try Self.validate(putResponse, body: body)

    guard let assetURL = URL(string: metadata.assetURL) else {
      throw VideoModerationServiceError.unexpectedResponse
    }
    return assetURL
  }

  /// Moderates one video and returns the `data` payload of the
  /// `generation.completed` SSE event.
  func detect(videoURL: URL) async throws -> Data {
    try await detect(DetectionRequest(model: Self.model, videoURL: videoURL.absoluteString))
  }

  /// Moderates one image and returns the `data` payload of the
  /// `generation.completed` SSE event.
  func detect(imageURL: URL) async throws -> Data {
    try await detect(DetectionRequest(model: Self.model, imageURLs: [imageURL.absoluteString]))
  }

  /// Moderates one string of text. Needs no upload — the text travels in the request
  /// body.
  func detect(text: String) async throws -> Data {
    try await detect(DetectionRequest(model: Self.model, text: text))
  }

  private func detect(_ body: DetectionRequest) async throws -> Data {
    guard !apiKey.isEmpty else {
      throw VideoModerationServiceError.missingAPIKey
    }

    var request = authorizedRequest(path: "v1/responses")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(body)

    let (bytes, response) = try await urlSession.bytes(for: request)
    guard let http = response as? HTTPURLResponse else {
      throw VideoModerationServiceError.unexpectedResponse
    }
    guard (200 ..< 300).contains(http.statusCode) else {
      throw VideoModerationServiceError.requestFailed(
        statusCode: http.statusCode,
        message: await Self.readBounded(bytes),
      )
    }

    return try await Self.completedPayload(from: bytes)
  }

  /// Reads the SSE stream and returns the payload of the `generation.completed`
  /// event, throwing if the stream carries a failure or ends without a result.
  ///
  /// Kept separate from the request setup so neither half has to be read while
  /// holding the other in mind.
  private static func completedPayload(from bytes: URLSession.AsyncBytes) async throws -> Data {
    var event = ""
    for try await line in bytes.lines {
      try Task.checkCancellation()
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      // Blank line (event separator) or SSE comment.
      if trimmed.isEmpty || trimmed.hasPrefix(":") {
        continue
      }
      if trimmed.hasPrefix("event:") {
        event = String(trimmed.dropFirst("event:".count)).trimmingCharacters(in: .whitespaces)
        continue
      }
      guard trimmed.hasPrefix("data:") else { continue }
      let payload = String(trimmed.dropFirst("data:".count)).trimmingCharacters(in: .whitespaces)
      guard let data = payload.data(using: .utf8) else { continue }
      switch event {
      case "generation.completed": return data
      case "generation.failed": throw VideoModerationServiceError.generationFailed(failureMessage(data))
      default: break
      }
      // Reset after each consumed data line so a later `data:` without its own
      // `event:` cannot inherit this event type.
      event = ""
    }
    throw VideoModerationServiceError.noResult
  }

  /// Builds a `POST` request to a gateway path with the Bearer auth header set.
  private func authorizedRequest(path: String) -> URLRequest {
    var request = URLRequest(url: gatewayURL.appendingPathComponent(path), timeoutInterval: Self.requestTimeout)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    return request
  }

  private static func validate(_ response: URLResponse, body: Data) throws {
    guard let http = response as? HTTPURLResponse else {
      throw VideoModerationServiceError.unexpectedResponse
    }
    guard (200 ..< 300).contains(http.statusCode) else {
      throw VideoModerationServiceError.requestFailed(
        statusCode: http.statusCode,
        message: String(bytes: body.prefix(4096), encoding: .utf8) ?? "",
      )
    }
  }

  /// The MIME type to declare for an upload, from the file extension. MP4 is the
  /// fallback for an unfamiliar extension.
  private static func contentType(for file: URL) -> String {
    switch file.pathExtension.lowercased() {
    case "mov": "video/quicktime"
    case "jpg", "jpeg": "image/jpeg"
    case "png": "image/png"
    case "heic", "heif": "image/heic"
    case "webp": "image/webp"
    case "gif": "image/gif"
    default: "video/mp4"
    }
  }

  private static func failureMessage(_ data: Data) -> String {
    if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      if let error = object["error"] as? [String: Any], let message = error["message"] as? String {
        return message
      }
      if let message = object["message"] as? String {
        return message
      }
    }
    // No recognised message field: surface the payload itself rather than a generic
    // string, so an unfamiliar failure shape can still be diagnosed.
    let payload = String(bytes: data.prefix(512), encoding: .utf8) ?? ""
    return payload.isEmpty ? "Moderation failed." : "Moderation failed: \(payload)"
  }

  /// Reads at most 4 KB of an error body, so a large response cannot balloon the
  /// error message.
  private static func readBounded(_ bytes: URLSession.AsyncBytes) async -> String {
    var data = Data()
    do {
      for try await byte in bytes {
        data.append(byte)
        if data.count >= 4096 {
          break
        }
      }
    } catch {
      // Best-effort: a truncated error body is not worth surfacing over the HTTP
      // status it accompanies.
    }
    return String(data: data, encoding: .utf8) ?? ""
  }
}

// MARK: - Gateway Payloads

/// The `/v1/uploads` response: a presigned `upload_url` to PUT bytes to, and the
/// `asset_url` to reference the uploaded asset in a subsequent run.
private struct UploadMetadata: Decodable {
  let uploadURL: String
  let assetURL: String

  enum CodingKeys: String, CodingKey {
    case uploadURL = "upload_url"
    case assetURL = "asset_url"
  }
}

/// The `POST /v1/responses` body for a moderation run: one video, image or text per
/// call. The unused fields are omitted.
private struct DetectionRequest: Encodable {
  let model: String
  var videoURL: String?
  var imageURLs: [String]?
  var text: String?

  enum CodingKeys: String, CodingKey {
    case model
    case videoURL = "video_url"
    case imageURLs = "image_urls"
    case text
  }
}

/// The shape of an `imgly/detection` `generation.completed` payload: one `output`
/// entry, carrying the normalized `scores` of an image or a text, or of every sampled
/// frame of a video.
private struct DetectionResponse: Decodable {
  let output: [Output]

  struct Output: Decodable {
    let data: Payload
  }

  struct Payload: Decodable {
    /// Confidence per category of an image or a text.
    let scores: [String: Double]?
    /// The sampled frames of a video.
    let frames: [Frame]?
  }

  struct Frame: Decodable {
    /// The frame's position in the source file, in milliseconds.
    let position: Double
    /// Confidence per category, e.g. `["nudity": 0.001, "weapon": 0.001]`.
    let scores: [String: Double]
  }
}

// MARK: - Errors

/// Errors thrown by moderation services.
public enum VideoModerationServiceError: LocalizedError {
  case missingAPIKey
  case requestFailed(statusCode: Int, message: String)
  case generationFailed(String)
  case noResult
  case unexpectedResponse

  /// Whether this error means the service rejected the credentials rather than the
  /// content — the caller should ask for a new API key rather than show a banner.
  public var isAuthenticationFailure: Bool {
    switch self {
    case .missingAPIKey:
      true
    case let .requestFailed(statusCode, _):
      statusCode == 401 || statusCode == 403
    default:
      false
    }
  }

  public var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      "No IMG.LY API key configured for the moderation service."
    case let .requestFailed(statusCode, message):
      message.isEmpty
        ? "The moderation service request failed with status code \(statusCode)."
        : "The moderation service request failed with status code \(statusCode): \(message)"
    case let .generationFailed(message):
      message
    case .noResult:
      "The moderation service stream ended without a result."
    case .unexpectedResponse:
      "The moderation service returned an unexpected response."
    }
  }
}
