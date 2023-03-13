import Foundation

protocol MappedEnum: MappedType, RawRepresentable<String>, CaseIterable, Labelable, IdentifiableByHash {}
