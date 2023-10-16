import Foundation

// MARK: - UnsplashResponse

struct UnsplashSearchResponse: Decodable {
  let total, totalPages: Int?
  let results: [UnsplashImage]
}

typealias UnsplashListResponse = [UnsplashImage]

// MARK: - Result

struct UnsplashImage: Decodable {
  let id: String
  let createdAt, updatedAt: String
  let promotedAt: String?
  let width, height: Int
  let color, blurHash: String?
  let description: String?
  let altDescription: String?
  let urls: Urls
  let likes: Int?
  let likedByUser: Bool?
  let user: User
  let tags: [Tag]?
}

// MARK: - Tag

struct Tag: Decodable {
  let type, title: String?
}

// MARK: - Urls

struct Urls: Decodable {
  let raw, full, regular, small: URL
  let thumb, smallS3: URL
}

// MARK: - User

struct User: Decodable {
  let id: String
  let updatedAt: String

  let username, name, firstName: String?
  let lastName, twitterUsername: String?
  let portfolioURL: String?
  let bio, location: String?
  let links: UserLinks?
  let instagramUsername: String?
  let totalCollections, totalLikes, totalPhotos: Int?
  let acceptedTos, forHire: Bool?
}

// MARK: - UserLinks

struct UserLinks: Decodable {
  let linksSelf, html, photos, likes: URL?
  let portfolio, following, followers: URL?
}
