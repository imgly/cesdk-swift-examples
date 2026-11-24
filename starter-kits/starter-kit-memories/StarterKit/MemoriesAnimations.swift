import IMGLYEngine

/// The slide animations for the Memories slideshow. **This is the file to edit.**
///
/// A slide's motion is one move that runs the whole clip: a slow Ken Burns drift the viewer barely
/// notices. The blend into the next slide is the style's transition, not an animation, so a slide
/// needs no out-animation to leave on. The kit picks one recipe at random per slide.
///
/// A recipe builds a **fresh** engine animation on each call. An engine animation belongs to one
/// design block, so assigning one animation to several slides re-points it to the newest slide only,
/// and destroying that slide later leaves the others holding a dangling ID.
struct MemoriesAnimationRecipe {
  let makeIn: @MainActor (_ engine: Engine) throws -> DesignBlockID
  /// A second move as the slide leaves. `nil` when the one move covers the whole clip.
  var makeOut: (@MainActor (_ engine: Engine) throws -> DesignBlockID)?
}

@MainActor
enum MemoriesAnimations {
  /// The pool of animations a slide can use. Edit this list to change the slideshow's motion.
  static let recipes: [MemoriesAnimationRecipe] = [
    kenBurnsDrift,
  ]

  // highlight-starter-kit-ken-burns-drift
  /// One slow Ken Burns across the whole clip: a gentle push in with a little drift, at a constant
  /// rate. An eased curve spends its speed early or late, which over a whole clip reads as the photo
  /// lurching and then crawling.
  ///
  /// Ken Burns is a pure transform while `animation/ken_burns/fade` stays at its `false` default.
  /// Leave it there: an animation that also ramps the alpha leaves both clips semi-transparent through
  /// the transition, and the backdrop shows through the blend.
  private static let kenBurnsDrift = MemoriesAnimationRecipe { engine in
    let animation = try engine.block.createAnimation(.kenBurns)
    // The whole clip, so the move is slow enough to read as life rather than motion.
    try engine.block.setDuration(animation, duration: MemoriesConstants.imageDuration)
    try engine.block.setFloat(animation, property: "animation/ken_burns/zoomIntensity", value: 0.2)
    // A full crop-length of travel reads as the photo sliding past; a third of it reads as drift.
    try engine.block.setFloat(animation, property: "animation/ken_burns/travelDistanceRatio", value: 0.3)
    try engine.block.setEnum(animation, property: "animationEasing", value: "Linear")
    return animation
  }
  // highlight-starter-kit-ken-burns-drift
}
