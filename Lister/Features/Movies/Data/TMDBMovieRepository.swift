//
//  TMDBMovieRepository.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct TMDBMovieRepository: MovieRepository {
    private let apiClient: APIClientProtocol
    private let imageURLBuilder: ImageURLBuilding
    private let movieLimit: Int?

    init(
        apiClient: APIClientProtocol,
        imageURLBuilder: ImageURLBuilding,
        movieLimit: Int? = nil
    ) {
        self.apiClient = apiClient
        self.imageURLBuilder = imageURLBuilder
        self.movieLimit = movieLimit
    }

    func fetchMoviePages() async throws -> [MoviePage] {
        let moviesResponse = try await apiClient.send(TMDBEndpoint.topRatedMovies())
        let movies = moviesResponse.results.limited(to: movieLimit)

        return await withTaskGroup(of: MoviePage?.self) { group in
            for movie in movies {
                group.addTask {
                    guard let credits = try? await apiClient.send(TMDBEndpoint.movieCredits(movieID: movie.id)) else { return nil }

                    let actors = credits.cast
                        .sorted { ($0.order ?? .max) < ($1.order ?? .max) }
                        .map { castMember in
                            Actor(
                                id: castMember.id,
                                fullName: castMember.name,
                                role: castMember.character?.nilIfBlank,
                                imageURL: imageURLBuilder.url(for: castMember.profilePath, size: .profile)
                            )
                        }

                    return MoviePage(
                        id: movie.id,
                        title: movie.title,
                        wallpaperURL: imageURLBuilder.url(for: movie.backdropPath, size: .backdrop),
                        actors: actors
                    )
                }
            }

            var pagesByID: [Int: MoviePage] = [:]
            for await page in group {
                guard let page else { continue }
                pagesByID[page.id] = page
            }

            return movies.compactMap { pagesByID[$0.id] }
        }
    }
}
