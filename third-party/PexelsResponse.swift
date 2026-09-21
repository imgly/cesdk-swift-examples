import Foundation

// MARK: - PexelsResponse

struct PexelsSearchResponse: Decodable {
  let totalResults: Int?
  let nextPage: String?
  let photos: [PexelsPhoto]

  enum CodingKeys: String, CodingKey {
    case totalResults = "total_results"
    case nextPage = "next_page"
    case photos
  }
}

// MARK: - Photo

struct PexelsPhoto: Decodable {
  let id: Int
  let width: Int
  let height: Int
  let photographer: String
  let photographerURL: String?
  let alt: String?
  let src: PexelsPhotoSource

  enum CodingKeys: String, CodingKey {
    case id, width, height, photographer, alt, src
    case photographerURL = "photographer_url"
  }
}

// MARK: - Source

struct PexelsPhotoSource: Decodable {
  let original: URL
  let medium: URL
}
