import Foundation
import IMGLYEngine

@MainActor
func buffers(engine: Engine) throws {
  // highlight-buffers-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-buffers-setup

  // highlight-buffers-createBuffer
  let audioBuffer = engine.editor.createBuffer()
  // highlight-buffers-createBuffer

  // highlight-buffers-writeData
  // Generate 10 seconds of stereo 48 kHz audio data
  let sampleCount = 10 * 2 * 48000
  let samples = ContiguousArray<Float>(unsafeUninitializedCapacity: sampleCount) { buffer, initializedCount in
    for i in stride(from: 0, to: buffer.count, by: 2) {
      let sample = sin((440.0 * Float(i) * Float.pi) / 48000.0)
      buffer[i + 0] = sample
      buffer[i + 1] = sample
    }
    initializedCount = buffer.count
  }

  // Write the audio samples to the buffer
  try samples.withUnsafeBufferPointer { buffer in
    try engine.editor.setBufferData(url: audioBuffer, offset: 0, data: Data(buffer: buffer))
  }
  // highlight-buffers-writeData

  // highlight-buffers-readData
  // Read a subrange of the buffer data
  let chunk = try engine.editor.getBufferData(url: audioBuffer, offset: 0, length: 4096)
  // highlight-buffers-readData

  // highlight-buffers-getLength
  // Query the current buffer length in bytes
  let length = try engine.editor.getBufferLength(url: audioBuffer)
  // highlight-buffers-getLength

  // highlight-buffers-resize
  // Reduce the buffer to half its length, truncating from 10 to 5 seconds
  try engine.editor.setBufferLength(url: audioBuffer, length: UInt(truncating: length) / 2)
  // highlight-buffers-resize

  // highlight-buffers-assignBlock
  // Create an audio block and assign the buffer as its source
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioBuffer)
  // highlight-buffers-assignBlock

  // highlight-buffers-transientResources
  // Find all transient resources in the scene, including buffers
  let transientResources = try engine.editor.findAllTransientResources()
  for resource in transientResources {
    print("Transient resource: \(resource.url), size: \(resource.size) bytes")
  }
  // highlight-buffers-transientResources

  // highlight-buffers-persistData
  // To persist buffer data, read it, upload to storage, then relocate
  let bufferData = try engine.editor.getBufferData(
    url: audioBuffer,
    offset: 0,
    length: UInt(truncating: try engine.editor.getBufferLength(url: audioBuffer)),
  )

  // In production, upload `bufferData` to a CDN or cloud storage
  let persistentURL = URL(string: "https://example.com/audio/generated.raw")!

  // Update all references to the old buffer URI throughout the scene
  try engine.editor.relocateResource(currentURL: audioBuffer, relocatedURL: persistentURL)
  // highlight-buffers-persistData

  // Free buffer resources when no longer needed
  try engine.editor.destroyBuffer(url: audioBuffer)

  _ = chunk
  _ = bufferData
}
