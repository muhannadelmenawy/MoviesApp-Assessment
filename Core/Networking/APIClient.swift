//
//  APIClient.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL, invalidResponse, status(Int), decoding(Error), other(Error)
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Invalid response."
        case .status(let c): return "Server error (\(c))."
        case .decoding(let e): return "Decoding failed: \(e.localizedDescription)"
        case .other(let e): return e.localizedDescription
        }
    }
}

protocol APIClientType { func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> }

final class APIClient: APIClientType {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    init(baseURL: URL = AppConfig.baseURL,
         apiKey: String = AppConfig.apiKey,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                        resolvingAgainstBaseURL: false) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        var items = endpoint.queryItems
        items.append(.init(name: "api_key", value: apiKey)) // v3
        comps.queryItems = items

        guard let url = comps.url else { return Fail(error: .invalidURL).eraseToAnyPublisher() }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 30
        req.addValue("application/json", forHTTPHeaderField: "accept")

        return session.dataTaskPublisher(for: req)
            .tryMap { output -> Data in
                guard let resp = output.response as? HTTPURLResponse else { throw APIError.invalidResponse }
                guard 200..<300 ~= resp.statusCode else {
                    let body = String(data: output.data, encoding: .utf8) ?? ""
                    print("TMDB error \(resp.statusCode): \(body)")
                    throw APIError.status(resp.statusCode)
                }
                return output.data
            }
            .mapError { $0 as? APIError ?? .other($0) }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { .decoding($0) }
            .eraseToAnyPublisher()
    }
}
