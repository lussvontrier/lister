//
//  APIClient.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

protocol APIClientProtocol: Sendable {
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

struct APIClient: APIClientProtocol {
    private let baseURL: URL
    private let authorizationToken: String
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        authorizationToken: String,
        httpClient: HTTPClient,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.authorizationToken = authorizationToken
        self.httpClient = httpClient
        self.decoder = decoder
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        guard !authorizationToken.isEmpty, authorizationToken != "$(TMDB_ACCESS_TOKEN)" else {
            throw APIError.missingAccessToken
        }

        var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await httpClient.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

enum APIError: LocalizedError, Equatable {
    case missingAccessToken
    case invalidURL
    case invalidResponse
    case server(statusCode: Int)
    case decoding(Error)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAccessToken, .missingAccessToken),
             (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            true
        case let (.server(lhsCode), .server(rhsCode)):
            lhsCode == rhsCode
        case (.decoding, .decoding):
            true
        default:
            false
        }
    }

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            "Add a TMDB v4 read access token to TMDB_ACCESS_TOKEN before running."
        case .invalidURL:
            "Could not build a valid request URL."
        case .invalidResponse:
            "The server returned an invalid response."
        case .server(let statusCode):
            "The server returned status code \(statusCode)."
        case .decoding:
            "Could not decode the response."
        }
    }
}
