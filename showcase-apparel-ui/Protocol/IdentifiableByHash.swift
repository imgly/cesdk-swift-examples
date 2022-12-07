import Foundation

protocol IdentifiableByHash: Hashable, Identifiable {}

extension IdentifiableByHash {
  var id: Int { hashValue }
}
