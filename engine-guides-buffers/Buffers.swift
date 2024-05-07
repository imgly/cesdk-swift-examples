import Foundation
import IMGLYEngine

@MainActor
func buffers(engine: Engine) throws {
  // highlight-setup
  let scene = try engine.scene.create()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  // highlight-setup

  // Create an audio block and append it to the page
  let audioBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: audioBlock)

  // Create a buffer
  // highlight-EditorAPI.createBuffer
  let audioBuffer = engine.editor.createBuffer()

  // Reference the audio buffer resource from the audio block
  try engine.block.setURL(audioBlock, property: "audio/fileURI", value: audioBuffer)

  // Generate 10 seconds of stereo 48 kHz audio data
  let samples = ContiguousArray<Float>(unsafeUninitializedCapacity: 10 * 2 * 48000) { buffer, initializedCount in
    for i in stride(from: 0, to: buffer.count, by: 2) {
      let sample = sin((440.0 * Float(i) * Float.pi) / 48000.0)
      buffer[i + 0] = sample
      buffer[i + 1] = sample
    }
    initializedCount = buffer.count
  }

  // Assign the audio data to the buffer
  try samples.withUnsafeBufferPointer { buffer in
    // highlight-EditorAPI.setBufferData
    try engine.editor.setBufferData(url: audioBuffer, offset: 0, data: Data(buffer: buffer))
  }

  // We can get subranges of the buffer data
  // highlight-EditorAPI.getBufferData
  let chunk = try engine.editor.getBufferData(url: audioBuffer, offset: 0, length: 4096)

  // Get current length of the buffer in bytes
  // highlight-EditorAPI.getBufferLength
  let length = try engine.editor.getBufferLength(url: audioBuffer)

  // Reduce the buffer to half its length, leading to 5 seconds worth of audio
  // highlight-EditorAPI.setBufferLength
  try engine.editor.setBufferLength(url: audioBuffer, length: UInt(truncating: length) / 2)

  // Free data
  // highlight-EditorAPI.destroyBuffer
  try engine.editor.destroyBuffer(url: audioBuffer)
}
