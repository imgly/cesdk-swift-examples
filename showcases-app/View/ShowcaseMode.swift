import Foundation

enum ShowcaseMode: CaseIterable, Identifiable, CustomStringConvertible {
  case navigationLink, fullScreenCover

  var id: Self { self }

  var description: String {
    switch self {
    case .navigationLink: "Navigation"
    case .fullScreenCover: "Modal"
    }
  }
}
