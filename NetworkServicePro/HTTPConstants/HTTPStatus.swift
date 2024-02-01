import Foundation

public enum HTTPStatus: Int, Error {
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    case alreadyReported = 208
    case unauthorized = 401
    case paymentRequired = 402
    case conflict = 409
    case upgradeRequired = 426
    case serviceUnavailable = 503
    case undefined = -1
}
