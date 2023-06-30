import SwiftUI

public struct Geometry: Equatable {
  public init(_ proxy: GeometryProxy, _ coordinateSpace: CoordinateSpace) {
    frame = proxy.frame(in: coordinateSpace)
    safeAreaInsets = proxy.safeAreaInsets
    self.coordinateSpace = coordinateSpace
  }

  public let frame: CGRect
  public let safeAreaInsets: EdgeInsets
  public let coordinateSpace: CoordinateSpace

  // Adds the `safeAreaInsets` to `frame.size`.
  public var size: CGSize {
    CGSize(width: frame.width + safeAreaInsets.leading + safeAreaInsets.trailing,
           height: frame.height + safeAreaInsets.top + safeAreaInsets.bottom)
  }
}
