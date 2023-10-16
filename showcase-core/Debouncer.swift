import Combine
import Foundation

public class Debouncer<T>: ObservableObject {
  @Published public var value: T
  @Published public var debouncedValue: T

  public init(initialValue: T, delay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)) {
    _value = .init(initialValue: initialValue)
    _debouncedValue = .init(initialValue: initialValue)

    $value
      .debounce(for: delay, scheduler: DispatchQueue.main)
      .assign(to: &$debouncedValue)
  }
}
