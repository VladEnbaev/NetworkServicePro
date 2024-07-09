import Foundation

struct EncoderUtils {
  
  // MARK: - Query Params
  
  static func urlEncode(request: inout URLRequest, queryParams: QueryParameters) throws {
    print()
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
  
  
  // MARK: - Body
  
  static func jsonEncode(request: inout URLRequest, body: Body) throws {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    let jsonEncoded = try jsonEncoder.encode(body)
    request.httpBody = jsonEncoded
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  }
  
  static func formUrlEncode(request: inout URLRequest, body: Body) throws {
    let jsonData = try JSONEncoder().encode(body)
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
    
    guard let jsonDictionary = jsonObject as? [String : Any] else {
      throw NetworkServiceError.invalidEncodableParams
    }
    
    let queryString = EncoderUtils.queryString(from: jsonDictionary)
    request.httpBody = queryString.data(using: .utf8)
    
    request.setValue(
      "application/x-www-form-urlencoded; charset=utf-8",
      forHTTPHeaderField: "Content-Type"
    )
  }
  
  static func queryString(from dictionary: [String: Any]) -> String {
    
    var parts: [String] = []
    
    for (key, value) in dictionary {
      let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      let encodedValue: String
      
      if let arrayValue = value as? [Any] {
        let encodedArrayValue = arrayValue.map {
          "\($0)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        
        encodedValue = encodedArrayValue.joined(separator: ",")
      } else {
        encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      }
      
      let part = "\(encodedKey)=\(encodedValue)"
      
      parts.append(part)
    }
    return parts.joined(separator: "&")
  }
}
