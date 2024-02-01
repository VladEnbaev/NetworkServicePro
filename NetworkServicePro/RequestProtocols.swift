import Foundation

public protocol AnyRequestPath {
    associatedtype Model: Decodable
    var urlPath: String { get }
    var method: HTTPMethod { get }
    var queryParams: QueryParameters? { get }
    var body: Body? { get }
}
