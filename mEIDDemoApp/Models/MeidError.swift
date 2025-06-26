import Foundation

public enum MeidError: Error, Equatable {
    case deeplinkNotSupported
    case authError
    case logoutError
}
