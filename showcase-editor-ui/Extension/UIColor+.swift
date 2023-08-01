import UIKit

extension UIColor: HSBAConvertible {
  var hsba: HSBA? { HSBA(self) }
}
