import SwiftUI

struct Geometry: Equatable {
  init(_ proxy: GeometryProxy, _ coordinateSpace: CoordinateSpace) {
    frame = proxy.frame(in: coordinateSpace)
    safeAreaInsets = proxy.safeAreaInsets
    self.coordinateSpace = coordinateSpace
  }

  let frame: CGRect
  let safeAreaInsets: EdgeInsets
  let coordinateSpace: CoordinateSpace

  // Adds the `safeAreaInsets` to `frame.size`.
  var size: CGSize {
    CGSize(width: frame.width + safeAreaInsets.leading + safeAreaInsets.trailing,
           height: frame.height + safeAreaInsets.top + safeAreaInsets.bottom)
  }
}
