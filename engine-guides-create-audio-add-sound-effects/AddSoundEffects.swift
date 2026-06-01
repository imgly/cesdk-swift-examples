import Foundation
import IMGLYEngine

@MainActor
func addSoundEffects(engine: Engine) async throws {
  // highlight-addSoundEffects-wavHelper
  func createWavData(
    sampleRate: Int,
    durationSeconds: Double,
    generator: (Double) -> Double,
  ) -> Data {
    let bitsPerSample: UInt16 = 16
    let channels: UInt16 = 2 // Stereo output
    let numSamples = Int(durationSeconds * Double(sampleRate))
    let dataSize = UInt32(numSamples * Int(channels) * Int(bitsPerSample / 8))

    var data = Data(capacity: 44 + Int(dataSize))

    func writeLE16(_ value: UInt16) {
      var le = value.littleEndian
      withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
    }
    func writeLE32(_ value: UInt32) {
      var le = value.littleEndian
      withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
    }
    func writeSample(_ value: Int16) {
      var le = value.littleEndian
      withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
    }

    // RIFF chunk descriptor
    data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
    writeLE32(36 + dataSize) // File size - 8
    data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"

    // fmt sub-chunk
    data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
    writeLE32(16) // Sub-chunk size (16 for PCM)
    writeLE16(1) // Audio format (1 = PCM)
    writeLE16(channels)
    writeLE32(UInt32(sampleRate))
    writeLE32(UInt32(sampleRate) * UInt32(channels) * UInt32(bitsPerSample / 8))
    writeLE16(channels * (bitsPerSample / 8)) // Block align
    writeLE16(bitsPerSample)

    // data sub-chunk
    data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
    writeLE32(dataSize)

    // Generate audio samples — duplicate mono value to both stereo channels.
    for i in 0 ..< numSamples {
      let time = Double(i) / Double(sampleRate)
      let value = generator(time)
      let clamped = max(-1.0, min(1.0, value))
      let sample = Int16((clamped * 32767.0).rounded())
      writeSample(sample) // Left channel
      writeSample(sample) // Right channel
    }

    return data
  }
  // highlight-addSoundEffects-wavHelper

  // highlight-addSoundEffects-envelopeHelper
  func adsr(
    time: Double,
    noteStart: Double,
    noteDuration: Double,
    attack: Double,
    decay: Double,
    sustain: Double,
    release: Double,
  ) -> Double {
    let t = time - noteStart
    guard t >= 0 else { return 0 }

    let noteEnd = noteDuration - release

    if t < attack {
      // Attack phase: ramp up from 0 to 1
      return t / attack
    } else if t < attack + decay {
      // Decay phase: ramp down from 1 to sustain level
      return 1 - ((t - attack) / decay) * (1 - sustain)
    } else if t < noteEnd {
      // Sustain phase: hold at sustain level
      return sustain
    } else if t < noteDuration {
      // Release phase: ramp down from sustain to 0
      return sustain * (1 - (t - noteEnd) / release)
    }
    return 0
  }
  // highlight-addSoundEffects-envelopeHelper

  // highlight-addSoundEffects-soundDefinitions
  struct Note {
    let freq: Double
    let start: Double
    let duration: Double
  }
  struct SoundEffect {
    let notes: [Note]
    let totalDuration: Double
  }

  // Musical note frequencies (Hz) for the 4th and 5th octaves.
  enum Notes {
    static let c4 = 261.63
    static let e4 = 329.63
    static let g4 = 392.0
    static let a4 = 440.0
    static let c5 = 523.25
    static let d5 = 587.33
    static let e5 = 659.25
    static let f5 = 698.46
    static let g5 = 783.99
    static let a5 = 880.0
  }

  // Sound effect 1: Ascending "success" fanfare with overlapping arpeggio and chord.
  let successChime = SoundEffect(
    notes: [
      Note(freq: Notes.c4, start: 0.0, duration: 0.4),
      Note(freq: Notes.e4, start: 0.1, duration: 0.4),
      Note(freq: Notes.g4, start: 0.2, duration: 0.5),
      Note(freq: Notes.c5, start: 0.35, duration: 1.65),
      Note(freq: Notes.e5, start: 0.4, duration: 1.6),
      Note(freq: Notes.g5, start: 0.45, duration: 1.55),
    ],
    totalDuration: 2.0,
  )

  // Sound effect 2: Gentle notification melody that resolves pleasantly.
  let notificationMelody = SoundEffect(
    notes: [
      Note(freq: Notes.e5, start: 0.0, duration: 0.4),
      Note(freq: Notes.g5, start: 0.25, duration: 0.5),
      Note(freq: Notes.a5, start: 0.6, duration: 0.3),
      Note(freq: Notes.g5, start: 0.85, duration: 0.4),
      Note(freq: Notes.e5, start: 1.15, duration: 0.85),
    ],
    totalDuration: 2.0,
  )

  // Sound effect 3: Descending alert tone that grabs attention.
  let alertTone = SoundEffect(
    notes: [
      Note(freq: Notes.a5, start: 0.0, duration: 0.25),
      Note(freq: Notes.a5, start: 0.3, duration: 0.25),
      Note(freq: Notes.f5, start: 0.6, duration: 0.4),
      Note(freq: Notes.d5, start: 0.9, duration: 0.5),
      Note(freq: Notes.a4, start: 1.3, duration: 0.7),
    ],
    totalDuration: 2.0,
  )
  // highlight-addSoundEffects-soundDefinitions

  // highlight-addSoundEffects-setup
  let scene = try engine.scene.createVideo()
  let page = try engine.block.create(.page)
  try engine.block.appendChild(to: scene, child: page)
  try engine.block.setWidth(page, value: 1920)
  try engine.block.setHeight(page, value: 1080)

  // Total duration: 3 effects × 2s + 2 gaps × 0.5s = 7s
  let effectDuration = 2.0
  let gapDuration = 0.5
  let totalDuration = 3 * effectDuration + 2 * gapDuration
  try engine.block.setDuration(page, duration: totalDuration)

  let sampleRate = 48000
  // highlight-addSoundEffects-setup

  // highlight-addSoundEffects-bufferCreate
  let chimeBuffer = engine.editor.createBuffer()
  // highlight-addSoundEffects-bufferCreate

  // Generate the chime samples using the WAV helper.
  let chimeWav = createWavData(
    sampleRate: sampleRate,
    durationSeconds: successChime.totalDuration,
  ) { time in
    var sample = 0.0
    for note in successChime.notes {
      let envelope = adsr(
        time: time,
        noteStart: note.start,
        noteDuration: note.duration,
        attack: 0.02, // Soft attack (20ms)
        decay: 0.08, // Gentle decay (80ms)
        sustain: 0.7, // Sustain at 70%
        release: 0.25, // Smooth release (250ms)
      )
      if envelope > 0 {
        // Sine wave with two harmonics for a richer tone.
        let fundamental = sin(2 * .pi * note.freq * time)
        let harmonic2 = sin(4 * .pi * note.freq * time) * 0.25
        let harmonic3 = sin(6 * .pi * note.freq * time) * 0.1
        sample += (fundamental + harmonic2 + harmonic3) * envelope * 0.3
      }
    }
    return sample
  }

  // highlight-addSoundEffects-bufferWrite
  try engine.editor.setBufferData(url: chimeBuffer, offset: 0, data: chimeWav)
  // highlight-addSoundEffects-bufferWrite

  // highlight-addSoundEffects-bufferRead
  let chimeLength = try engine.editor.getBufferLength(url: chimeBuffer)
  let chimeBytes = try engine.editor.getBufferData(
    url: chimeBuffer,
    offset: 0,
    length: chimeLength.uintValue,
  )
  // highlight-addSoundEffects-bufferRead

  _ = chimeBytes

  // highlight-addSoundEffects-audioTrack
  let chimeBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: chimeBlock)
  try engine.block.setURL(chimeBlock, property: "audio/fileURI", value: chimeBuffer)
  // highlight-addSoundEffects-audioTrack

  // highlight-addSoundEffects-timelinePosition
  // Position the chime at the start of the timeline.
  try engine.block.setTimeOffset(chimeBlock, offset: 0)
  try engine.block.setDuration(chimeBlock, duration: successChime.totalDuration)
  try engine.block.setVolume(chimeBlock, volume: 0.8)
  // highlight-addSoundEffects-timelinePosition

  // highlight-addSoundEffects-generateMelody
  let melodyBuffer = engine.editor.createBuffer()
  let melodyWav = createWavData(
    sampleRate: sampleRate,
    durationSeconds: notificationMelody.totalDuration,
  ) { time in
    var sample = 0.0
    for note in notificationMelody.notes {
      let envelope = adsr(
        time: time,
        noteStart: note.start,
        noteDuration: note.duration,
        attack: 0.01,
        decay: 0.06,
        sustain: 0.6,
        release: 0.2,
      )
      if envelope > 0 {
        let fundamental = sin(2 * .pi * note.freq * time)
        let harmonic2 = sin(4 * .pi * note.freq * time) * 0.15
        sample += (fundamental + harmonic2) * envelope * 0.4
      }
    }
    return sample
  }
  try engine.editor.setBufferData(url: melodyBuffer, offset: 0, data: melodyWav)

  let melodyBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: melodyBlock)
  try engine.block.setURL(melodyBlock, property: "audio/fileURI", value: melodyBuffer)
  try engine.block.setTimeOffset(melodyBlock, offset: effectDuration + gapDuration) // 2.5s
  try engine.block.setDuration(melodyBlock, duration: notificationMelody.totalDuration)
  try engine.block.setVolume(melodyBlock, volume: 0.8)
  // highlight-addSoundEffects-generateMelody

  // highlight-addSoundEffects-generateAlert
  let alertBuffer = engine.editor.createBuffer()
  let alertWav = createWavData(
    sampleRate: sampleRate,
    durationSeconds: alertTone.totalDuration,
  ) { time in
    var sample = 0.0
    for note in alertTone.notes {
      let envelope = adsr(
        time: time,
        noteStart: note.start,
        noteDuration: note.duration,
        attack: 0.005,
        decay: 0.05,
        sustain: 0.5,
        release: 0.15,
      )
      if envelope > 0 {
        let fundamental = sin(2 * .pi * note.freq * time)
        let harmonic2 = sin(4 * .pi * note.freq * time) * 0.2
        let harmonic3 = sin(6 * .pi * note.freq * time) * 0.15
        sample += (fundamental + harmonic2 + harmonic3) * envelope * 0.35
      }
    }
    return sample
  }
  try engine.editor.setBufferData(url: alertBuffer, offset: 0, data: alertWav)

  let alertBlock = try engine.block.create(.audio)
  try engine.block.appendChild(to: page, child: alertBlock)
  try engine.block.setURL(alertBlock, property: "audio/fileURI", value: alertBuffer)
  try engine.block.setTimeOffset(alertBlock, offset: 2 * (effectDuration + gapDuration)) // 5s
  try engine.block.setDuration(alertBlock, duration: alertTone.totalDuration)
  try engine.block.setVolume(alertBlock, volume: 0.75)
  // highlight-addSoundEffects-generateAlert

  // highlight-addSoundEffects-export
  let archive = try await engine.scene.saveToArchive()
  // highlight-addSoundEffects-export

  _ = archive
}
