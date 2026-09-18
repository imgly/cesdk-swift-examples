import Foundation

// MARK: - GettyImagesResponse

struct GettyImagesSearchResponse: Decodable {
  let resultCount: Int?
  let images: [GettyImage]

  enum CodingKeys: String, CodingKey {
    case resultCount = "result_count"
    case images
  }
}

// MARK: - Image

struct GettyImage: Decodable {
  let id: String
  let title: String?
  let maxDimensions: GettyImageDimensions?
  let displaySizes: [GettyDisplaySize]

  enum CodingKeys: String, CodingKey {
    case id, title
    case maxDimensions = "max_dimensions"
    case displaySizes = "display_sizes"
  }
}

// MARK: - Dimensions

struct GettyImageDimensions: Decodable {
  let width: Int?
  let height: Int?
}

// MARK: - Display size

struct GettyDisplaySize: Decodable {
  let name: String
  let uri: URL
}
