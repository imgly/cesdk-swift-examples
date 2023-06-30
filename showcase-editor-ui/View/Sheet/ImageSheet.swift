import IMGLYCoreUI
import SwiftUI

struct ImageSheet: View {
  @EnvironmentObject private var interactor: Interactor
  private var sheet: SheetModel { interactor.sheet.model }

  @State private var imageSource = ImageSource.images

  @ViewBuilder var imageSourcePicker: some View {
    Picker("Image Source", selection: $imageSource) {
      ForEach(ImageSource.allCases) { source in
        source.taggedLabel
      }
    }
    .pickerStyle(.segmented)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Image Source")
  }

  @ViewBuilder func imageGrid(for imageSource: ImageSource) -> some View {
    VStack {
      // Needs to be in VStack to keep `imageSourcePicker` animation.
      // Needs to be an explicit switch to update the view.
      switch imageSource {
      case .uploads:
        UploadGrid(interactor: interactor, sourceID: imageSource.sourceID, search: $searchText.debouncedValue)
      case .images:
        ImageGrid(interactor: interactor, sourceID: imageSource.sourceID, search: $searchText.debouncedValue)
      case .unsplash:
        ImageGrid(interactor: interactor, sourceID: imageSource.sourceID, search: $searchText.debouncedValue)
      }
    }
  }

  @State var navigationBarHeight: CGFloat?
  @State var pickerHeight: CGFloat?
  var backgroundHeight: CGFloat? {
    var value: CGFloat?
    if let navigationBarHeight {
      value = navigationBarHeight
    }
    if let pickerHeight {
      value = (value ?? 0) + pickerHeight
    }
    return value
  }

  @StateObject private var searchText = Debouncer(initialValue: "")

  @ViewBuilder var imageSources: some View {
    imageGrid(for: imageSource)
      .overlay(alignment: .top) {
        Rectangle()
          .fill(.bar)
          .frame(height: backgroundHeight)
          .ignoresSafeArea()
      }
      .safeAreaInset(edge: .top, spacing: 0) {
        imageSourcePicker
          .padding([.leading, .trailing])
          .padding([.bottom], 10)
          .background {
            GeometryReader { geo in
              Color.clear
                .preference(key: PickerHeightKey.self, value: geo.size.height)
            }
          }
      }
      .background {
        GeometryReader { geo in
          Color.clear
            .preference(key: NavigationBarHeightKey.self, value: geo.safeAreaInsets.top)
        }
      }
      .onPreferenceChange(NavigationBarHeightKey.self) { newValue in
        navigationBarHeight = newValue
      }
      .onPreferenceChange(PickerHeightKey.self) { newValue in
        pickerHeight = newValue
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          AddImageButton()
        }
        ToolbarItemGroup(placement: .principal) {
          SearchField(searchText: $searchText.value, prompt: Text("Search Images"))
        }
      }
  }

  var body: some View {
    BottomSheet {
      switch sheet.mode {
      case .add, .replace: imageSources
      case .crop: CropOptions()
      case .fillAndStroke: FillAndStrokeOptions()
      case .layer: LayerOptions()
      default: EmptyView()
      }
    }
  }
}

private struct NavigationBarHeightKey: PreferenceKey {
  static let defaultValue: CGFloat? = nil
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    value = value ?? nextValue()
  }
}

private struct PickerHeightKey: PreferenceKey {
  static let defaultValue: CGFloat? = nil
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    value = value ?? nextValue()
  }
}

struct ImageSheet_Previews: PreviewProvider {
  static var previews: some View {
    defaultPreviews(sheet: .init(.add, .image))
  }
}
