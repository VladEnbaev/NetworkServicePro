import Foundation

public protocol AnyEndpoint {
  /// Адрес сервера
  var host: String { get }
  
  /// Конечная точка адреса
  var path: String { get }
  
  /// Метод отправки данных
  var method: HTTPMethod { get }
  
  /// Параметры запроса
  var queryParams: QueryParameters? { get }
  
  /// Дополнительные заголовки, основные уже проставлены
  var additionalHeaders: Headers? { get }
  
  /// Тип контента
  var contentType: HTTPContentType { get }
  
  /// Тело Запроса
  var body: Body? { get }
}
