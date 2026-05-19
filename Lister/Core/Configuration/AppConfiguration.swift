//
//  AppConfiguration.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct AppConfiguration: Sendable {
    let tmdbAPIBaseURL: URL
    let tmdbImageBaseURL: URL
    let tmdbAccessToken: String

    static func current(bundle: Bundle = .main) throws -> AppConfiguration {
        AppConfiguration(
            tmdbAPIBaseURL: try makeURL(from: "https://api.themoviedb.org/3"),
            tmdbImageBaseURL: try makeURL(from: "https://image.tmdb.org/t/p"),
            tmdbAccessToken: bundle.object(forInfoDictionaryKey: "TMDBAccessToken") as? String ?? .empty
        )
    }

    private static func makeURL(from string: String) throws -> URL {
        guard
            let url = URL(string: string),
            url.scheme == "https",
            url.host != nil
        else {
            throw AppConfigurationError.invalidURL(string)
        }

        return url
    }
}

enum AppConfigurationError: LocalizedError, Equatable {
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let value):
            "Invalid app configuration URL: \(value)"
        }
    }
}
