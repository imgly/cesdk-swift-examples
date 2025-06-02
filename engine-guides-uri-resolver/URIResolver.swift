import Foundation
import IMGLYEngine

@MainActor
func uriResolver(engine: Engine) async throws {
  // highlight-get-absolute-base-path
  // This will return "https://cdn.img.ly/packages/imgly/cesdk-js/1.53.0-rc.0/assets/banana.jpg"
  try engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")
  // highlight-get-absolute-base-path

  // highlight-resolver
  // Replace all .jpg files with the IMG.LY logo!
  try engine.editor.setURIResolver { uri in
    if uri.hasSuffix(".jpg") {
      return URL(string: "https://img.ly/static/ubq_samples/imgly_logo.jpg")!
    }
    // Make use of the default URI resolution behavior.
    return URL(string: engine.editor.defaultURIResolver(relativePath: uri))!
  }
  // highlight-resolver

  // highlight-get-absolute-custom
  // The custom resolver will return a path to the IMG.LY logo because the given path ends with ".jpg".
  // This applies regardless if the given path is relative or absolute.
  try engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")

  // The custom resolver will not modify this path because it ends with ".png".
  try engine.editor.getAbsoluteURI(relativePath: "https://example.com/orange.png")

  // Because a custom resolver is set, relative paths that the resolver does not transform remain unmodified!
  try engine.editor.getAbsoluteURI(relativePath: "/orange.png")
  // highlight-get-absolute-custom

  // highlight-remove-resolver
  // Removes the previously set resolver.
  try engine.editor.setURIResolver(nil)

  // Since we"ve removed the custom resolver, this will return
  // "https://cdn.img.ly/packages/imgly/cesdk-js/1.53.0-rc.0/assets/banana.jpg" like before.
  try engine.editor.getAbsoluteURI(relativePath: "/banana.jpg")
  // highlight-remove-resolver
}
