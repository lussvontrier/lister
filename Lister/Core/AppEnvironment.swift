//
//  AppEnvironment.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct AppEnvironment {
    let movieRepository: MovieRepository
    let movieStatisticsProvider: MovieStatisticsProviding

    static func live() throws -> AppEnvironment {
        let configuration = try AppConfiguration.current()
        let sessionClient = URLSessionHTTPClient(session: .shared)
        let apiClient = APIClient(
            baseURL: configuration.tmdbAPIBaseURL,
            authorizationToken: configuration.tmdbAccessToken,
            httpClient: sessionClient,
            decoder: .tmdb
        )
        let imageURLBuilder = TMDBImageURLBuilder(baseURL: configuration.tmdbImageBaseURL)

        return AppEnvironment(
            movieRepository: TMDBMovieRepository(
                apiClient: apiClient,
                imageURLBuilder: imageURLBuilder
            ),
            movieStatisticsProvider: MovieStatisticsProvider()
        )
    }
}
