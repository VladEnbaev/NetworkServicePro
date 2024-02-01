import Foundation

struct EncoderUtils {

    static func jsonEncode(request: inout URLRequest, body: Body) throws {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonEncoded = try jsonEncoder.encode(body)
            request.httpBody = jsonEncoded
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw NetworkServiceError.invalidEncodableParams
        }
    }

    static func urlEncode(request: inout URLRequest, queryParams: QueryParameters) throws {
        guard let url = request.url else { throw NetworkServiceError.invalidEncodableParams }
        guard !queryParams.isEmpty,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        urlComponents.queryItems = [URLQueryItem]()
        queryParams
            .compactMapValues { $0 }
            .forEach { (key: String, value: String) in
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let item = URLQueryItem(name: key, value: encodedValue)
                urlComponents.queryItems?.append(item)
            }
        request.url = urlComponents.url
        request.setValue(
            "application/x-www-form-urlencoded; charset=utf-8",
            forHTTPHeaderField: "Content-Type"
        )
    }
}
