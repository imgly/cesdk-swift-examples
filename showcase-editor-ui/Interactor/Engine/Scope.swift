import Foundation

public typealias Scope = RawRepresentableKey<ScopeKey>

public enum ScopeKey: String {
  case designStyle = "design/style"
  case designArrange = "design/arrange"
  case designArrangeMove = "design/arrange/move"
  case designArrangeResize = "design/arrange/resize"
  case designArrangeRotate = "design/arrange/rotate"
  case designArrangeFlip = "design/arrange/flip"

  case contentReplace = "content/replace"

  case lifecycleDestroy = "lifecycle/destroy"
  case lifecycleDuplicate = "lifecycle/duplicate"

  case editorAdd = "editor/add"
  case editorSelect = "editor/select"
}
