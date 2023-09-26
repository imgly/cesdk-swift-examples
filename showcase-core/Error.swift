import Foundation

public struct Error: LocalizedError {
  public let errorDescription: String?

  public init(errorDescription: String?) {
    self.errorDescription = errorDescription
  }
}
