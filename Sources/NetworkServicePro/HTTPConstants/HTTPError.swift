import Foundation

public enum HTTPError: Int, Error {
  case badRequest = 400
  case unauthorized = 401
  case paymentRequired = 402
  case forbidden = 403
  case conflict = 409
  case upgradeRequired = 426
  
  case serviceUnavailable = 503
  case gatewayTimeout = 504
  
  case undefined = -1
}
