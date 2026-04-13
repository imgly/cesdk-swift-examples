import Foundation
import IMGLYEngine

// Dummy implementation of a server-side URI resolver.
func getResolvedUriFromServer(uri: String) async throws -> URL {
  URL(string: uri)!
}

@MainActor
func uriResolver(engine: Engine) async throws {
  // highlight-get-absolute-base-path
  // This will return "https://cdn.img.ly/packages/imgly/cesdk-js/1.72.3-rc.0/assets/banana.jpg"
  try await engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")
  // highlight-get-absolute-base-path

  // highlight-resolver
  try engine.editor.setURIResolverAsync { uri async throws -> URL in
    // Resolve protected URIs by calling a backend that returns a resolvable URL.
    if uri.hasSuffix(".jpg") {
      return try await getResolvedUriFromServer(uri: uri)
    }
    // Make use of the default URI resolution behavior.
    return await URL(string: engine.editor.defaultURIResolver(relativePath: uri))!
  }
  // highlight-resolver

  // highlight-get-absolute-custom
  try await engine.editor.getAbsoluteURI(relativePath: "s3://my-private-bucket/path/to/banana.jpg")

  try await engine.editor.getAbsoluteURI(relativePath: "https://example.com/orange.png")

  try await engine.editor.getAbsoluteURI(relativePath: "/orange.png")
  // highlight-get-absolute-custom

  // highlight-remove-resolver
  // Removes the previously set resolver.
  try engine.editor.setURIResolverAsync(nil)

  // Since we've removed the custom resolver, this will return
  // "https://cdn.img.ly/packages/imgly/cesdk-js/1.72.3-rc.0/assets/banana.jpg" like before.
  try await engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")
  // highlight-remove-resolver
}
