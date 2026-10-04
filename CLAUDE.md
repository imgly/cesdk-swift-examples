# iOS Examples and Showcases (`apps/cesdk_swift_examples`)

First-time setup: `./scripts/dev/setup-ios-dev.sh`, after installing Xcode.

Xcode projects are generated from YAML specs. Never edit a `.xcodeproj`; run `make` again after adding or removing
files.

For UI work without engine changes, try these in order:

```bash
make generateWithLocalUI                              # local IMGLYUI, published engine
make downloadNightlyEngine generateWithLocalEngine    # published engine is too old for the UI
```

If both fail, build the engine from source with `bindings/apple/generate_xcode_project.py` (see
`bindings/apple/DEVELOPMENT.md`). That project names its schemes differently, such as `showcases-app` instead of
`CESDK-Showcases`.

```bash
make generateWithLocalUI
xcodebuild -project CESDK-Showcases.xcodeproj -scheme CESDK-Showcases \
  -destination "platform=iOS Simulator,name=<an installed iPhone>" build
```
