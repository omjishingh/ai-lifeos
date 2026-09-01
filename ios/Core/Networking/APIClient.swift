import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkUnavailable
    case unauthorized
    case serverError(Int)
    case decodingFailed(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request."
        case .networkUnavailable: return "No internet connection."
        case .unauthorized: return "Authentication required."
        case .serverError(let code): return "Server error (\(code))."
        case .decodingFailed: return "Failed to process response."
        case .unknown(let error): return error.localizedDescription
        }
    }
}

protocol APIClientProtocol {
    func get<T: Decodable>(_ path: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T
}

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
}

final class NetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
}

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let networkMonitor: NetworkMonitorProtocol

    init(
        baseURL: URL = APIConfig.baseURL,
        session: URLSession = .shared,
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.networkMonitor = networkMonitor
    }

    func get<T: Decodable>(_ path: String) async throws -> T {
        guard networkMonitor.isConnected else { throw APIError.networkUnavailable }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        guard networkMonitor.isConnected else { throw APIError.networkUnavailable }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        switch httpResponse.statusCode {
        case 200...299: return
        case 401: throw APIError.unauthorized
        default: throw APIError.serverError(httpResponse.statusCode)
        }
    }
}
