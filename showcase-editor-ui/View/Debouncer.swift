import Combine
import Foundation

class Debouncer<T>: ObservableObject {
  @Published var value: T
  @Published var debouncedValue: T

  init(initialValue: T, delay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)) {
    _value = .init(initialValue: initialValue)
    _debouncedValue = .init(initialValue: initialValue)

    $value
      .debounce(for: delay, scheduler: DispatchQueue.main)
      .assign(to: &$debouncedValue)
  }
}
