import Foundation

/// Перечисление ошибок происходящие в работе NetworkService
public enum NetworkServiceError: Error, Equatable {
    /// Ошибка в параметрах запроса
    case invalidEncodableParams
  
    /// Некорректный урл адрес
    case invalidUrl
  
    /// Сессия не инициализирована
    case invalidSession
  
    /// Ответ сервера недействителен (неожиданный формат)
    case invalidResponse
  
    /// Ошибка парсинга ответа с сервера
    case parseError(String)
}
