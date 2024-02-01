import Foundation

public struct OptionalModelObject<T: Decodable>: Decodable {
    public let value: T?

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            value = try container.decode(T.self)
        } catch {
            value = nil
        }
    }
}

/// Контейнер для модели
public struct NetworkResponse<T: Decodable>: Decodable {
    public let data: T
}

/// Ошибка
public struct NetworkErrorResponse: Decodable {
    let timestamp: Int
    let errorMessage: String
}

/// Тип используется для возвращаемого значения имеющего данные от сервера
public struct DataResponse<T: Decodable> {
    public let model: T
    public let status: HTTPStatus
}
