//
//  TMDBEndpoint.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

enum TMDBEndpoint {
    static func topRatedMovies() -> Endpoint<TMDBPagedResponse<TMDBMovieDTO>> {
        Endpoint(
            path: "movie/top_rated",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US")
            ]
        )
    }

    static func movieCredits(movieID: Int) -> Endpoint<TMDBCreditsResponse> {
        Endpoint(
            path: "movie/\(movieID)/credits",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US")
            ]
        )
    }
}
