import PhotosUI
import SwiftUI
import UIKit

/// A reusable modal view for image generation
public struct ImageGenerationView: View {
  // MARK: - Properties

  /// The delegate that handles generation actions
  public var delegate: (any ImageGenerationDelegate)?

  /// The UI configuration
  public let configuration: ImageGenerationUIConfiguration

  /// Environment for dismissing the modal
  @Environment(\.dismiss) var dismiss

  // MARK: - State

  @State private var settings = GenerationSettings()
  @State private var showTransparencyInfo = false
  @State private var sourceImageData: Data?
  @State private var sourceImage: UIImage?
  @State private var selectedPhotoItem: PhotosPickerItem?

  // MARK: - Initialization

  public init(
    delegate: (any ImageGenerationDelegate)?,
    configuration: ImageGenerationUIConfiguration
  ) {
    self.delegate = delegate
    self.configuration = configuration
  }

  // MARK: - Body

  public var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        TextGenerationView(
          settings: $settings,
          showTransparencyInfo: $showTransparencyInfo,
          sourceImage: $sourceImage,
          sourceImageData: $sourceImageData,
          selectedPhotoItem: $selectedPhotoItem,
          configuration: textGenerationConfiguration,
        )

        generateButton
      }
      .navigationTitle(configuration.navigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if configuration.showsCancelButton {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              dismiss()
            } label: {
              Image(systemName: "chevron.down.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary)
                .font(.title2)
            }
            .buttonStyle(.borderless)
          }
        }
      }
    }
    .onChange(of: sourceImageData) { _ in
      settings.sourceImageData = sourceImageData
      if sourceImageData != nil {
        settings.mode = .imageToImage
      } else {
        settings.mode = .textToImage
      }
    }
    .onChange(of: selectedPhotoItem) { _ in
      Task {
        if let item = selectedPhotoItem,
           let data = try? await item.loadTransferable(type: Data.self) {
          sourceImageData = data
          sourceImage = UIImage(data: data)
        } else {
          sourceImageData = nil
          sourceImage = nil
        }
      }
    }
    .onAppear {
      settings.mode = .textToImage
    }
  }

  // MARK: - Private Views

  @ViewBuilder
  private var generateButton: some View {
    Button(action: generate) {
      Label(configuration.generateButtonTitle, systemImage: "sparkles")
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding()
    .disabled(isGenerateButtonDisabled)
    .background(Color(.systemGroupedBackground).ignoresSafeArea())
  }

  // MARK: - Computed Properties

  private var isGenerateButtonDisabled: Bool {
    settings.prompt.isEmpty
  }

  private var textGenerationConfiguration: TextGenerationConfiguration {
    TextGenerationConfiguration(
      showsPromptInput: true,
      showsOutputTypeSelector: configuration.showsVectorOption,
      showsStyleSelector: true,
      showsFormatSelector: configuration.showsFormatSelector,
      showsBackgroundSelector: configuration.showsTransparencyOption,
      showsTransparencyInfo: configuration.showsTransparencyOption,
      enablesImageToImage: configuration.enablesImageToImage,
      availableImageStyles: ImageStyle.allCases,
      availableVectorStyles: configuration.showsVectorOption ? VectorStyle.allCases : [],
      availableFormats: FormatOption.allCases,
      availableBackgrounds: BackgroundOption.allCases,
    )
  }

  // MARK: - Private Methods

  private func generate() {
    var finalSettings = settings
    finalSettings.sourceImageData = sourceImageData

    if sourceImageData != nil {
      finalSettings.mode = .imageToImage
    } else {
      finalSettings.mode = .textToImage
      finalSettings.sourceImageData = nil
    }

    let capturedDelegate = delegate
    dismiss()

    Task { @MainActor in
      await capturedDelegate?.generateImage(with: finalSettings)
    }
  }
}
