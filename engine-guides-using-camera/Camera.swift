import AVFoundation
import Foundation

@frozen
enum VideoCapture {
  case frame(CVImageBuffer)
  case videoCaptured(URL)
}

final class Camera: NSObject {
  private lazy var queue = DispatchQueue(label: "ly.img.camera", qos: .userInteractive)

  private var videoContinuation: AsyncThrowingStream<VideoCapture, Error>.Continuation?

  private let videoInput: AVCaptureDeviceInput
  private let audioInput: AVCaptureDeviceInput

  private var captureSession: AVCaptureSession!
  private var movieOutput: AVCaptureMovieFileOutput

  init(
    videoDevice: AVCaptureDevice = .default(for: .video)!,
    audioDevice: AVCaptureDevice = .default(for: .audio)!
  ) throws {
    videoInput = try AVCaptureDeviceInput(device: videoDevice)
    audioInput = try AVCaptureDeviceInput(device: audioDevice)
    movieOutput = AVCaptureMovieFileOutput()
  }

  func captureVideo(toURL fileURL: URL = .init(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4"))
    -> AsyncThrowingStream<VideoCapture, Error> {
    .init { continuation in
      videoContinuation = continuation

      captureSession = AVCaptureSession()
      captureSession.addInput(videoInput)
      captureSession.addInput(audioInput)

      let videoOutput = AVCaptureVideoDataOutput()
      videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
      videoOutput.setSampleBufferDelegate(self, queue: queue)

      captureSession.addOutput(videoOutput)

      captureSession.addOutput(movieOutput)

      queue.async {
        self.captureSession.startRunning()
        self.movieOutput.startRecording(to: fileURL, recordingDelegate: self)
      }

      continuation.onTermination = { _ in
        self.queue.async {
          self.movieOutput.stopRecording()
          self.captureSession.stopRunning()
        }
      }
    }
  }

  func stopCapturing() {
    queue.async {
      self.movieOutput.stopRecording()
      self.captureSession?.stopRunning()
    }
  }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from _: AVCaptureConnection
  ) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    videoContinuation?.yield(.frame(pixelBuffer))
  }
}

extension Camera: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(
    _: AVCaptureFileOutput,
    didStartRecordingTo _: URL,
    from _: [AVCaptureConnection]
  ) {}
  func fileOutput(
    _: AVCaptureFileOutput,
    didFinishRecordingTo url: URL,
    from _: [AVCaptureConnection],
    error: Error?
  ) {
    if let error {
      videoContinuation?.finish(throwing: error)
    } else {
      videoContinuation?.yield(.videoCaptured(url))
      videoContinuation?.finish()
    }
  }
}
