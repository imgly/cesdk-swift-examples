import PhotosUI
import SwiftUI
import UIKit
import WebKit

private let thumbnailBaseURL =
  "https://cdn.img.ly/assets/plugins/plugin-ai-image-generation-web/v1/recraft-v3/thumbnails"

/// A reusable text-to-image generation view component
public struct TextGenerationView: View {
  @Binding var settings: GenerationSettings
  @Binding var showTransparencyInfo: Bool
  @Binding var sourceImage: UIImage?
  @Binding var sourceImageData: Data?
  @Binding var selectedPhotoItem: PhotosPickerItem?

  public let configuration: TextGenerationConfiguration

  @FocusState private var promptIsFocused: Bool
  @State private var showCustomDimensionsInput = false
  @State private var showAllStyles = false

  public init(
    settings: Binding<GenerationSettings>,
    showTransparencyInfo: Binding<Bool>,
    sourceImage: Binding<UIImage?> = .constant(nil),
    sourceImageData: Binding<Data?> = .constant(nil),
    selectedPhotoItem: Binding<PhotosPickerItem?> = .constant(nil),
    configuration: TextGenerationConfiguration = .default
  ) {
    _settings = settings
    _showTransparencyInfo = showTransparencyInfo
    _sourceImage = sourceImage
    _sourceImageData = sourceImageData
    _selectedPhotoItem = selectedPhotoItem
    self.configuration = configuration
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: configuration.sectionSpacing) {
        // Prompt input
        if configuration.showsPromptInput {
          promptInputSection
        }

        // Output, Style & Format controls (horizontal scroll row)
        if configuration.showsOutputTypeSelector || configuration.showsStyleSelector
          || configuration.showsFormatSelector {
          controlsRow
        }

        // Background selector (only for image output)
        if configuration.showsBackgroundSelector, settings.outputType == .image {
          backgroundSelectionSection
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground).ignoresSafeArea())
    .onTapGesture {
      promptIsFocused = false
    }
    .onChange(of: settings.format) { _ in
      showCustomDimensionsInput = (settings.format == .custom)
    }
    .alert(String(localized: "ai_generation_transparency_title", table: aiGenerationTable),
           isPresented: $showTransparencyInfo) {
      Button(String(localized: "ai_generation_got_it", table: aiGenerationTable), role: .cancel) {}
    } message: {
      Text(configuration.transparencyInfoMessage)
    }
    .sheet(isPresented: $showCustomDimensionsInput) {
      customDimensionsSheet
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
  }

  // MARK: - Custom Dimensions Alert

  private var customDimensionsSheet: some View {
    VStack(spacing: 16) {
      Text(String(localized: "ai_generation_custom_size", table: aiGenerationTable))
        .font(.headline)

      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "ai_generation_width", table: aiGenerationTable))
            .font(.caption)
            .foregroundColor(.secondary)
          TextField("1024", value: $settings.customWidth, format: .number)
            .font(.title3.monospacedDigit())
            .keyboardType(.numberPad)
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "ai_generation_height", table: aiGenerationTable))
            .font(.caption)
            .foregroundColor(.secondary)
          TextField("1024", value: $settings.customHeight, format: .number)
            .font(.title3.monospacedDigit())
            .keyboardType(.numberPad)
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
      }

      HStack(spacing: 12) {
        Button {
          settings.format = .squareHD
          showCustomDimensionsInput = false
        } label: {
          Text(String(localized: "ai_generation_cancel", table: aiGenerationTable))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        Button {
          showCustomDimensionsInput = false
        } label: {
          Text(String(localized: "ai_generation_apply", table: aiGenerationTable))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
    }
    .padding(20)
  }

  @ViewBuilder
  private var promptInputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Unified prompt card with optional image picker
      VStack(alignment: .leading, spacing: 0) {
        // Inline image picker (if enabled)
        if configuration.enablesImageToImage {
          imagePickerRow
            .padding(.top, 10)
            .padding(.horizontal, 10)
        }

        // Text editor with placeholder
        ZStack(alignment: .topLeading) {
          if settings.prompt.isEmpty {
            Text(String(localized: "ai_generation_prompt_placeholder", table: aiGenerationTable))
              .foregroundColor(Color(.placeholderText))
              .padding(.horizontal, 12)
              .padding(.vertical, 16)
          }
          TextEditor(text: $settings.prompt)
            .frame(minHeight: configuration.promptMinHeight)
            .padding(8)
            .focused($promptIsFocused)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
      }
      .background(configuration.promptBackgroundColor)
      .cornerRadius(configuration.promptCornerRadius)
    }
  }

  @ViewBuilder
  private var imagePickerRow: some View {
    if let image = sourceImage {
      // Thumbnail with remove button
      HStack(spacing: 8) {
        ZStack(alignment: .topTrailing) {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 64, height: 64)
            .clipped()
            .cornerRadius(8)

          Button {
            sourceImage = nil
            sourceImageData = nil
            selectedPhotoItem = nil
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.primary)
              .frame(width: 20, height: 20)
              .background(Color(.systemBackground))
              .clipShape(Circle())
              .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
          }
          .offset(x: 6, y: -6)
        }
        Spacer()
      }
    } else {
      // "+ Add image (optional)" button
      PhotosPicker(
        selection: $selectedPhotoItem,
        matching: .images,
        photoLibrary: .shared(),
      ) {
        HStack(alignment: .center, spacing: 3) {
          Image(systemName: "plus")
            .font(.system(size: 12, weight: .medium))
          Text(String(localized: "ai_generation_add_image", table: aiGenerationTable))
            .font(.subheadline)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(.quaternarySystemFill))
        .cornerRadius(40)
      }
    }
  }

  @ViewBuilder
  private var controlsRow: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .bottom, spacing: 12) {
        if configuration.showsOutputTypeSelector {
          outputButton.fixedSize()
        }

        if configuration.showsOutputTypeSelector, configuration.showsStyleSelector {
          Divider()
            .frame(height: 44)
        }

        if configuration.showsStyleSelector {
          styleButton.fixedSize()
        }

        if configuration.showsFormatSelector, sourceImage == nil {
          formatButton.fixedSize()
        }
      }
      .fixedSize()
      .padding(.horizontal)
    }
    .padding(.horizontal, -16)
  }

  // MARK: - Output Button

  private var outputButton: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(String(localized: "ai_generation_output", table: aiGenerationTable))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.leading, 14)

      Menu {
        ForEach(OutputType.allCases, id: \.self) { type in
          Button {
            settings.outputType = type
          } label: {
            Label(type.rawValue, systemImage: type.iconName)
          }
        }
      } label: {
        HStack(spacing: 4) {
          Image(systemName: settings.outputType.iconName)
            .font(.subheadline)
          Text(settings.outputType.rawValue)
            .font(.subheadline)
        }
        .frame(minWidth: 80, alignment: .center)
        .foregroundColor(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.quaternarySystemFill))
        .cornerRadius(40)
      }
    }
  }

  // MARK: - Style Button

  private var styleButton: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(currentStyleLabel)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.leading, 14)

      Button {
        showAllStyles = true
      } label: {
        HStack(spacing: 8) {
          styleThumbnailView
            .frame(width: 32, height: 36)
            .background(.black)
            .clipShape(StyleThumbnailShape())
            .overlay(
              StyleThumbnailShape()
                .inset(by: 0.25)
                .stroke(Color(.separator), lineWidth: 0.5),
            )

          Text(currentStyleName)
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding(.trailing, 14)
        .padding(.leading, 2)
        .padding(.vertical, 2)
        .background(Color(.quaternarySystemFill))
        .cornerRadius(40)
      }
    }
    .sheet(isPresented: $showAllStyles) {
      AllStylesSheet(
        outputType: settings.outputType,
        imageStyles: configuration.availableImageStyles,
        vectorStyles: configuration.availableVectorStyles,
        selectedImageStyle: settings.imageStyle,
        selectedVectorStyle: settings.vectorStyle,
        onImageStyleSelected: { style in
          var transaction = Transaction()
          transaction.disablesAnimations = true
          withTransaction(transaction) {
            settings.imageStyle = style
          }
        },
        onVectorStyleSelected: { style in
          var transaction = Transaction()
          transaction.disablesAnimations = true
          withTransaction(transaction) {
            settings.vectorStyle = style
          }
        },
      )
    }
  }

  // MARK: - Format Button

  private var formatButton: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(String(localized: "ai_generation_aspect_ratio", table: aiGenerationTable))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.leading, 14)

      formatMenu
    }
  }

  @ViewBuilder
  private var formatMenu: some View {
    Menu {
      ForEach(configuration.availableFormats, id: \.self) { format in
        if format == .custom {
          Button {
            settings.format = format
            showCustomDimensionsInput = true
          } label: {
            Label(format.rawValue, systemImage: format.iconName)
          }
        } else {
          Button {
            settings.format = format
          } label: {
            Label(format.shortLabel, systemImage: format.iconName)
          }
        }
      }
    } label: {
      HStack(spacing: 4) {
        Image(systemName: settings.format.iconName)
          .font(.subheadline)
        Text(formatButtonLabel)
          .font(.subheadline)
          .lineLimit(1)
      }
      .frame(minWidth: 150, alignment: .center)
      .foregroundColor(.primary)
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(Color(.quaternarySystemFill))
      .cornerRadius(40)
    }
  }

  private var formatButtonLabel: String {
    if settings.format == .custom {
      return "\(settings.customWidth) x \(settings.customHeight)"
    }
    return settings.format.shortLabel
  }

  private var currentStyleLabel: String {
    settings.outputType == .image
      ? String(localized: "ai_generation_image_style", table: aiGenerationTable)
      : String(localized: "ai_generation_vector_style", table: aiGenerationTable)
  }

  private var currentStyleName: String {
    settings.outputType == .image ? settings.imageStyle.rawValue : settings.vectorStyle.rawValue
  }

  private var currentStyleThumbnailURL: String {
    if settings.outputType == .image {
      "\(thumbnailBaseURL)/\(settings.imageStyle.previewImageName).webp"
    } else {
      "\(thumbnailBaseURL)/\(settings.vectorStyle.previewImageName).svg"
    }
  }

  @ViewBuilder
  private var styleThumbnailView: some View {
    let url = currentStyleThumbnailURL
    if url.hasSuffix(".svg") {
      SVGImageView(
        url: url,
        contentMode: .fill,
        placeholder: {
          Color(.systemGray5)
        },
      )
      .id(url)
    } else {
      AsyncImage(url: URL(string: url)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Color(.systemGray5)
      }
    }
  }

  private var backgroundSelectionSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(configuration.backgroundSectionTitle)
          .font(.headline)

        if settings.background == .transparent, configuration.showsTransparencyInfo {
          Button {
            showTransparencyInfo = true
          } label: {
            Image(systemName: "info.circle")
              .foregroundColor(.blue)
          }
        }
      }

      Picker(String(localized: "ai_generation_background", table: aiGenerationTable), selection: $settings.background) {
        ForEach(configuration.availableBackgrounds, id: \.self) { option in
          Text(option.rawValue).tag(option)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }
}

// MARK: - Shapes

/// Asymmetric thumbnail shape: left side fully rounded (100pt), right side 16pt radius.
struct StyleThumbnailShape: InsettableShape {
  var insetAmount: CGFloat = 0

  func path(in rect: CGRect) -> Path {
    let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
    return Path(
      roundedRect: insetRect,
      cornerRadii: RectangleCornerRadii(
        topLeading: 100,
        bottomLeading: 100,
        bottomTrailing: 8,
        topTrailing: 8,
      ),
    )
  }

  func inset(by amount: CGFloat) -> StyleThumbnailShape {
    var shape = self
    shape.insetAmount += amount
    return shape
  }
}

// MARK: - UI Components

/// Full-screen style picker sheet
struct AllStylesSheet: View {
  let outputType: OutputType
  let imageStyles: [ImageStyle]
  let vectorStyles: [VectorStyle]
  let selectedImageStyle: ImageStyle
  let selectedVectorStyle: VectorStyle
  let onImageStyleSelected: (ImageStyle) -> Void
  let onVectorStyleSelected: (VectorStyle) -> Void

  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 20) {
          if outputType == .image {
            // Realistic Image Section
            let realisticStyles = imageStyles.filter { style in
              style == .realisticImage || style.styleId.starts(with: "realistic_image/")
            }
            if !realisticStyles.isEmpty {
              let realisticBase = String(localized: "ai_generation_realistic_image", table: aiGenerationTable)
              let realisticTitle = "\(realisticBase) (\(realisticStyles.count))"
              StyleGridSection(
                title: realisticTitle,
                imageStyles: realisticStyles,
                selectedImageStyle: selectedImageStyle,
                onImageStyleSelected: { style in
                  onImageStyleSelected(style)
                  dismiss()
                },
              )
            }

            // Digital Illustration Section
            let digitalStyles = imageStyles.filter { style in
              style == .digitalIllustration || style.styleId.starts(with: "digital_illustration/")
            }
            if !digitalStyles.isEmpty {
              let digitalBase = String(localized: "ai_generation_digital_illustration", table: aiGenerationTable)
              let digitalTitle = "\(digitalBase) (\(digitalStyles.count))"
              StyleGridSection(
                title: digitalTitle,
                imageStyles: digitalStyles,
                selectedImageStyle: selectedImageStyle,
                onImageStyleSelected: { style in
                  onImageStyleSelected(style)
                  dismiss()
                },
              )
            }
          } else {
            // Vector styles
            let vectorBase = String(localized: "ai_generation_vector_illustration", table: aiGenerationTable)
            let vectorTitle = "\(vectorBase) (\(vectorStyles.count))"
            VectorStyleGridSection(
              title: vectorTitle,
              vectorStyles: vectorStyles,
              selectedVectorStyle: selectedVectorStyle,
              onVectorStyleSelected: { style in
                onVectorStyleSelected(style)
                dismiss()
              },
            )
          }
        }
        .padding()
      }
      .navigationTitle(String(localized: "ai_generation_select_style", table: aiGenerationTable))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "ai_generation_done", table: aiGenerationTable)) {
            dismiss()
          }
        }
      }
    }
  }
}

/// Grid section for image styles
struct StyleGridSection: View {
  let title: String
  let imageStyles: [ImageStyle]
  let selectedImageStyle: ImageStyle
  let onImageStyleSelected: (ImageStyle) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.title2)
        .fontWeight(.semibold)

      LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 100))], spacing: 8) {
        ForEach(imageStyles, id: \.self) { style in
          StyleThumbnailCard(
            title: style.rawValue,
            imageURL: "\(thumbnailBaseURL)/\(style.previewImageName).webp",
            isSelected: selectedImageStyle == style,
            action: {
              onImageStyleSelected(style)
            },
          )
        }
      }
    }
  }
}

/// Grid section for vector styles
struct VectorStyleGridSection: View {
  let title: String
  let vectorStyles: [VectorStyle]
  let selectedVectorStyle: VectorStyle
  let onVectorStyleSelected: (VectorStyle) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.title2)
        .fontWeight(.semibold)

      LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 100))], spacing: 8) {
        ForEach(vectorStyles, id: \.self) { style in
          StyleThumbnailCard(
            title: style.rawValue,
            imageURL: "\(thumbnailBaseURL)/\(style.previewImageName).svg",
            isSelected: selectedVectorStyle == style,
            action: {
              onVectorStyleSelected(style)
            },
          )
        }
      }
    }
  }
}

/// Unified card view for style selection — matches the core editor filter item pattern.
struct StyleThumbnailCard: View {
  let title: String
  let imageURL: String
  let isSelected: Bool
  let action: () -> Void

  private let thumbnailSize: CGFloat = 80
  private let imageCornerRadius: CGFloat = 8
  private let borderCornerRadius: CGFloat = 10
  private let borderPadding: CGFloat = 4

  var body: some View {
    Button(action: action) {
      VStack(spacing: 3) {
        thumbnailImage
          .frame(width: thumbnailSize, height: thumbnailSize)
          .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
          .padding(borderPadding)
          .overlay(
            RoundedRectangle(cornerRadius: borderCornerRadius)
              .inset(by: 1)
              .stroke(Color.accentColor, lineWidth: 2)
              .opacity(isSelected ? 1 : 0),
          )

        Text(title)
          .font(.caption2)
          .lineLimit(2, reservesSpace: true)
          .truncationMode(.tail)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary)
      }
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var thumbnailImage: some View {
    if imageURL.hasSuffix(".svg") {
      SVGImageView(
        url: imageURL,
        contentMode: .fill,
        placeholder: { thumbnailPlaceholder },
      )
    } else {
      CachedRemoteImage(url: imageURL) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        thumbnailPlaceholder
      }
    }
  }

  private var thumbnailPlaceholder: some View {
    RoundedRectangle(cornerRadius: imageCornerRadius)
      .fill(.linearGradient(
        .init(colors: [Color(.quaternarySystemFill), Color(.systemFill)]),
        startPoint: .top,
        endPoint: .bottom,
      ))
  }
}

// MARK: - Thumbnail Cache

/// Simple in-memory cache for style thumbnail data and rendered images
final class ThumbnailCache: @unchecked Sendable {
  static let shared = ThumbnailCache()

  private let dataCache = NSCache<NSString, NSData>()
  private let imageCache = NSCache<NSString, UIImage>()

  private init() {
    dataCache.countLimit = 120
    imageCache.countLimit = 120
  }

  func data(for key: String) -> Data? {
    dataCache.object(forKey: key as NSString) as Data?
  }

  func setData(_ data: Data, for key: String) {
    dataCache.setObject(data as NSData, forKey: key as NSString)
  }

  func image(for key: String) -> UIImage? {
    imageCache.object(forKey: key as NSString)
  }

  func setImage(_ image: UIImage, for key: String) {
    imageCache.setObject(image, forKey: key as NSString)
  }
}

/// Cached remote image view for raster thumbnails (replaces AsyncImage)
struct CachedRemoteImage<Content: View, Placeholder: View>: View {
  let url: String
  let content: (Image) -> Content
  let placeholder: () -> Placeholder

  @State private var uiImage: UIImage?
  @State private var isLoading = true

  init(
    url: String,
    @ViewBuilder content: @escaping (Image) -> Content,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.url = url
    self.content = content
    self.placeholder = placeholder
  }

  var body: some View {
    Group {
      if let uiImage {
        content(Image(uiImage: uiImage))
      } else {
        placeholder()
      }
    }
    .onAppear { load() }
    .onChange(of: url) { _ in
      uiImage = nil
      isLoading = true
      load()
    }
  }

  private func load() {
    if let cached = ThumbnailCache.shared.data(for: url), let img = UIImage(data: cached) {
      uiImage = img
      isLoading = false
      return
    }

    guard let requestURL = URL(string: url) else {
      isLoading = false
      return
    }

    URLSession.shared.dataTask(with: requestURL) { data, _, _ in
      DispatchQueue.main.async {
        if let data {
          ThumbnailCache.shared.setData(data, for: url)
          uiImage = UIImage(data: data)
        }
        isLoading = false
      }
    }.resume()
  }
}

/// SVG-compatible image view that caches rendered images to avoid WKWebView re-creation
struct SVGImageView<Placeholder: View>: View {
  let url: String
  let contentMode: ContentMode
  let placeholder: () -> Placeholder

  @State private var renderedImage: UIImage?
  @State private var svgData: Data?
  @State private var isLoading = true

  init(
    url: String,
    contentMode: ContentMode = .fit,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.url = url
    self.contentMode = contentMode
    self.placeholder = placeholder
  }

  var body: some View {
    Group {
      if let renderedImage {
        Image(uiImage: renderedImage)
          .resizable()
          .aspectRatio(contentMode: contentMode)
      } else if let svgData, !svgData.isEmpty {
        SVGWebView(svgData: svgData) { image in
          renderedImage = image
          ThumbnailCache.shared.setImage(image, for: url)
        }
      } else if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        placeholder()
      }
    }
    .onAppear {
      load()
    }
    .onChange(of: url) { _ in
      renderedImage = nil
      svgData = nil
      isLoading = true
      load()
    }
  }

  private func load() {
    // 1. Check for previously rendered image
    if let cached = ThumbnailCache.shared.image(for: url) {
      renderedImage = cached
      isLoading = false
      return
    }

    // 2. Check for cached raw data
    if let cached = ThumbnailCache.shared.data(for: url) {
      if let img = UIImage(data: cached) {
        renderedImage = img
        ThumbnailCache.shared.setImage(img, for: url)
      } else {
        svgData = cached
      }
      isLoading = false
      return
    }

    // 3. Fetch from network
    guard let requestURL = URL(string: url) else {
      isLoading = false
      return
    }

    URLSession.shared.dataTask(with: requestURL) { data, _, _ in
      DispatchQueue.main.async {
        if let data {
          ThumbnailCache.shared.setData(data, for: url)
          if let img = UIImage(data: data) {
            renderedImage = img
            ThumbnailCache.shared.setImage(img, for: url)
          } else {
            svgData = data
          }
        }
        isLoading = false
      }
    }.resume()
  }
}

/// WebKit-based SVG renderer that snapshots itself after rendering for caching
struct SVGWebView: UIViewRepresentable {
  let svgData: Data
  let onRendered: (UIImage) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onRendered: onRendered)
  }

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.backgroundColor = .clear
    webView.isOpaque = false
    webView.scrollView.isScrollEnabled = false
    webView.scrollView.bounces = false
    webView.navigationDelegate = context.coordinator
    context.coordinator.webView = webView

    if let svgString = String(data: svgData, encoding: .utf8) {
      let html = """
      <!DOCTYPE html>
      <html>
      <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
              body { margin: 0; padding: 0; display: flex;
                justify-content: center; align-items: center;
                height: 100vh; background: transparent; }
              svg { max-width: 100%; max-height: 100%; }
          </style>
      </head>
      <body>
          \(svgString)
      </body>
      </html>
      """
      webView.loadHTMLString(html, baseURL: nil)
    }
    return webView
  }

  func updateUIView(_: WKWebView, context _: Context) {}

  class Coordinator: NSObject, WKNavigationDelegate {
    weak var webView: WKWebView?
    let onRendered: (UIImage) -> Void

    init(onRendered: @escaping (UIImage) -> Void) {
      self.onRendered = onRendered
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak webView] in
        guard let webView else { return }
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true
        webView.takeSnapshot(with: config) { [weak self] image, _ in
          if let image {
            DispatchQueue.main.async {
              self?.onRendered(image)
            }
          }
        }
      }
    }
  }
}
