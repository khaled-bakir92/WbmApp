//
//  APIClient.swift
//  WBM Bot Controller
//
//  Created on 2026-01-16.
//

import Foundation

/// Zentrale Netzwerk-Schicht für alle API-Calls
/// Singleton-Pattern für gemeinsame URLSession-Nutzung
actor APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    
    /// Führt einen HTTP-Request aus und dekodiert die Response
    /// - Parameters:
    ///   - method: HTTP-Methode (GET, POST, PUT, DELETE)
    ///   - path: API-Pfad (z.B. "/api/bot/status")
    ///   - body: Optional: Request-Body als Encodable-Objekt
    /// - Returns: Dekodiertes Response-Objekt vom Typ T
    func request<T: Decodable>(
        method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil
    ) async throws -> T {
        // Request erstellen
        guard let request = try createRequest(method: method, path: path, body: body) else {
            throw APIError.invalidURL
        }
        
        // Request ausführen
        let (data, response) = try await session.data(for: request)
        
        // HTTP Response validieren
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Status Code prüfen
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // JSON dekodieren
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    /// Führt einen HTTP-Request aus ohne Response-Body (z.B. für Actions)
    /// - Parameters:
    ///   - method: HTTP-Methode
    ///   - path: API-Pfad
    ///   - body: Optional: Request-Body
    /// - Returns: Success-Response
    func requestWithoutResponse(
        method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil
    ) async throws -> SuccessResponse {
        return try await request(method: method, path: path, body: body)
    }
    
    // MARK: - Raw Data Request
    
    /// Führt einen HTTP-Request aus und gibt die Rohdaten zurück (z.B. für Bilder)
    /// - Parameters:
    ///   - method: HTTP-Methode
    ///   - path: API-Pfad
    ///   - body: Optional: Request-Body
    /// - Returns: Response-Daten als Data
    func dataRequest(
        method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil
    ) async throws -> Data {
        guard let request = try createRequest(method: method, path: path, body: body) else {
            throw APIError.invalidURL
        }
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        return data
    }
    
    // MARK: - Request Builder
    
    private func createRequest(
        method: HTTPMethod,
        path: String,
        body: (any Encodable)? = nil
    ) throws -> URLRequest? {
        guard let url = APIConfig.url(for: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(APIConfig.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - API Error

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

// MARK: - Generic Response Models

/// Standard Success Response für Actions ohne spezifischen Return-Wert
struct SuccessResponse: Decodable {
    let success: Bool
    let message: String
    let pid: Int?
}
