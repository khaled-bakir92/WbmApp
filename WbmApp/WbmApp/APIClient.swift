//
//  APIClient.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige URL"
        case .invalidResponse:
            return "Ungültige Server-Antwort"
        case .httpError(let code):
            return "HTTP Fehler: \(code)"
        case .decodingError(let error):
            return "JSON Dekodierung fehlgeschlagen: \(error.localizedDescription)"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Request Builder
    
    private func createRequest(
        method: String,
        path: String,
        body: Data? = nil
    ) -> URLRequest? {
        guard let url = APIConfig.url(for: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(APIConfig.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Bot Status
    
    /// Holt den aktuellen Bot-Status vom Backend
    /// - Parameter completion: Result mit BotStatus oder APIError
    func fetchBotStatus(completion: @escaping (Result<BotStatus, APIError>) -> Void) {
        guard let request = createRequest(method: "GET", path: "/api/bot/status") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            // Netzwerkfehler
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // HTTP Response validieren
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // HTTP Status Code prüfen
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Response Data validieren
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // JSON dekodieren
            do {
                let decoder = JSONDecoder()
                let botStatus = try decoder.decode(BotStatus.self, from: data)
                completion(.success(botStatus))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
