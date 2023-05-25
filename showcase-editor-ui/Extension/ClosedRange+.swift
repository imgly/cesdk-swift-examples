import Foundation

extension ClosedRange where Bound: AdditiveArithmetic {
  var length: Bound {
    upperBound - lowerBound
  }
}
