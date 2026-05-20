//
//  MovieBrowserViewModelTests.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Testing
@testable import Lister

@MainActor
struct MovieBrowserViewModelTests {
    @Test
    func searchFiltersActorsByNameAndRole() async {
        let viewModel = MovieBrowserViewModel(
            repository: StubMovieRepository(
                pages: [
                    MoviePage(
                        id: 1,
                        title: "Movie",
                        wallpaperURL: nil,
                        actors: [
                            Actor(id: 1, fullName: "Lily Hart", role: "Detective", imageURL: nil),
                            Actor(id: 2, fullName: "Noah Vale", role: "Pilot", imageURL: nil)
                        ]
                    )
                ]
            ),
            statisticsProvider: MovieStatisticsProvider()
        )

        await viewModel.load()
        viewModel.updateSearchText("pilot")

        guard case .content(let content) = viewModel.presentation else {
            Issue.record("Expected loaded content")
            return
        }

        #expect(content.actorSection.actorRows.map(\.name) == ["Noah Vale"])
    }
}

private extension MovieActorSectionPresentation {
    var actorRows: [ActorRowPresentation] {
        rows.compactMap { row in
            guard case .actor(let actor) = row else { return nil }
            return actor
        }
    }
}

private struct StubMovieRepository: MovieRepository {
    let pages: [MoviePage]

    func fetchMoviePages() async throws -> [MoviePage] {
        pages
    }
}
