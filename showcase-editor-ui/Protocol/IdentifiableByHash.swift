import Foundation

protocol IdentifiableByHash: Hashable, Identifiable {}

extension IdentifiableByHash {
  public var id: Int { hashValue }
}
