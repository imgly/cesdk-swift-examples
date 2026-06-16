import Foundation
import IMGLYEngine

@MainActor
func addMusic(engine: Engine) async throws {
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1280)
  try engine.block.setHeight(page, value: 720)
  try engine.block.setDuration(page, duration: 30)

  // highlight-addMusic-createAudioBlock
  // Create an audio block and point it at an audio file.
  let audioBlock = try engine.block.create(.audio)
  try engine.block.setString(
    audioBlock,
    property: "audio/fileURI",
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets/ly.img.audio/audios/far_from_home.m4a",
  )
  try engine.block.appendChild(to: page, child: audioBlock)
  // highlight-addMusic-createAudioBlock

  // highlight-addMusic-configureTimeline
  // Wait for the audio resource to load before reading metadata such as duration.
  try await engine.block.forceLoadAVResource(audioBlock)

  // Read the total audio file length and offset playback to start three seconds in.
  let totalDuration = try engine.block.getAVResourceTotalDuration(audioBlock)
  try engine.block.setTimeOffset(audioBlock, offset: 3)
  try engine.block.setDuration(audioBlock, duration: min(totalDuration, 15))
  // highlight-addMusic-configureTimeline

  // highlight-addMusic-configureVolume
  // Set the block to 50% volume. Values range from 0.0 (silent) to 1.0 (full volume).
  try engine.block.setVolume(audioBlock, volume: 0.5)

  let currentVolume = try engine.block.getVolume(audioBlock)
  print(String(format: "Background music volume: %.0f%%", currentVolume * 100))
  // highlight-addMusic-configureVolume

  // highlight-addMusic-queryAudioAssets
  // Register the audio asset source by loading its content.json. The returned ID
  // matches the `id` field in the JSON (here, `ly.img.audio`).
  let audioSourceID = try await engine.asset.addLocalAssetSourceFromJSON(
    URL(string: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets/ly.img.audio/content.json")!,
  )

  // Query the first page of audio assets from the source.
  let results = try await engine.asset.findAssets(
    sourceID: audioSourceID,
    query: .init(query: nil, page: 0, perPage: 10),
  )
  print("Available audio assets: \(results.total)")
  // highlight-addMusic-queryAudioAssets

  // highlight-addMusic-applyAsset
  // Apply an asset result to add a new audio block configured from the asset's metadata.
  if let firstAsset = results.assets.first {
    let appliedBlock = try await engine.asset.apply(
      sourceID: audioSourceID,
      assetResult: firstAsset,
    )
    print("Created audio block from asset: \(appliedBlock.map(String.init) ?? "nil")")
  }
  // highlight-addMusic-applyAsset

  // highlight-addMusic-multipleAudio
  // Layer a second track from a different source on top of the first audio block.
  // The two blocks play simultaneously while their time ranges overlap.
  let backgroundAudio = try engine.block.create(.audio)
  try engine.block.setString(
    backgroundAudio,
    property: "audio/fileURI",
    value: "https://cdn.img.ly/packages/imgly/cesdk-swift/1.76.1-rc.0/assets/ly.img.audio/audios/dance_harder.m4a",
  )
  try engine.block.appendChild(to: page, child: backgroundAudio)
  try engine.block.setTimeOffset(backgroundAudio, offset: 10)
  try engine.block.setDuration(backgroundAudio, duration: 8)
  try engine.block.setVolume(backgroundAudio, volume: 0.2)
  // highlight-addMusic-multipleAudio

  // highlight-addMusic-listAudioBlocks
  // Iterate every audio block in the scene and read its current configuration.
  let audioBlocks = try engine.block.find(byType: .audio)
  for block in audioBlocks {
    let uri = try engine.block.getString(block, property: "audio/fileURI")
    let offset = try engine.block.getTimeOffset(block)
    let duration = try engine.block.getDuration(block)
    let volume = try engine.block.getVolume(block)
    print(String(format: "Audio %u — offset %.1fs, duration %.1fs, volume %.0f%%, uri %@",
                 block, offset, duration, volume * 100, uri))
  }
  // highlight-addMusic-listAudioBlocks

  // highlight-addMusic-removeAudio
  // Destroy an audio block to remove it from the scene and free its resources.
  try engine.block.destroy(backgroundAudio)
  // highlight-addMusic-removeAudio
}
