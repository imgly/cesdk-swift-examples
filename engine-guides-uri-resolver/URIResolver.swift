import Foundation
import IMGLYEngine

@MainActor
func uriResolver(engine: Engine) async throws {
  // highlight-test-resolution
  // Resolve a path without loading the asset. With no custom resolver, a relative
  // path is prefixed with the `basePath` setting and absolute paths pass through.
  let resolved = try await engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")
  print(resolved)
  // highlight-test-resolution

  // highlight-set-resolver
  try engine.editor.setURIResolver { [weak engine] uri in
    // Rewrite every .jpg request to the IMG.LY logo.
    if uri.hasSuffix(".jpg") {
      return URL(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!
    }
    // Delegate everything else to the default resolution behavior.
    guard let engine else { return URL(string: uri)! }
    return URL(string: engine.editor.defaultURIResolver(relativePath: uri))!
  }

  // The resolver runs for every request, so .jpg paths now resolve to the logo
  // whether they are relative or absolute.
  print(try await engine.editor.getAbsoluteURI(relativePath: "/banana.jpg"))
  // highlight-set-resolver

  // highlight-auth-resolver
  // Pre-compute the token; a synchronous resolver can't await a network call.
  let accessToken = "<your-access-token>"
  try engine.editor.setURIResolver { [weak engine] uri in
    guard let engine else { return URL(string: uri)! }
    let absoluteURI = engine.editor.defaultURIResolver(relativePath: uri)
    // Only protected assets need the token; pass everything else through unchanged.
    guard uri.contains("/protected/"), var components = URLComponents(string: absoluteURI) else {
      return URL(string: absoluteURI)!
    }
    components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "token", value: accessToken)]
    return components.url ?? URL(string: absoluteURI)!
  }
  // highlight-auth-resolver

  // highlight-auth-resolver-async
  // When the token or signed URL must be fetched per request, use the async
  // resolver and await your backend. Replace the stand-in with a real request.
  let requestSignedURL: @Sendable (String) async throws -> URL = { absoluteURI in
    URL(string: absoluteURI)!
  }
  try engine.editor.setURIResolverAsync { [weak engine] uri in
    guard let engine else { throw URLError(.cancelled) }
    let absoluteURI = await engine.editor.defaultURIResolver(relativePath: uri)
    guard uri.contains("/protected/") else { return URL(string: absoluteURI)! }
    return try await requestSignedURL(absoluteURI)
  }
  // highlight-auth-resolver-async

  // highlight-remove-resolver
  // Pass nil to remove the custom resolver and restore the default behavior.
  try engine.editor.setURIResolver(nil)
  print(try await engine.editor.getAbsoluteURI(relativePath: "/banana.jpg"))
  // highlight-remove-resolver
}
