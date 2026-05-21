//
//  MovieStatisticsTests.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Testing
@testable import Lister

struct MovieStatisticsTests {
    @Test
    func topCharactersAreCalculatedFromActorNames() {
        let actors = [
            Actor(id: 1, fullName: "Apple", role: nil, imageURL: nil),
            Actor(id: 2, fullName: "Banana", role: nil, imageURL: nil),
            Actor(id: 3, fullName: "Orange", role: nil, imageURL: nil),
            Actor(id: 4, fullName: "Blueberry", role: nil, imageURL: nil)
        ]

        let page = MoviePage(
            id: 1,
            title: "Example",
            wallpaperURL: nil,
            actors: actors
        )
        let statistics = MovieStatisticsProvider().statistics(for: page)

        #expect(statistics.movieTitle == "Example")
        #expect(statistics.itemCount == 4)
        #expect(statistics.topCharacters.map(\.character) == ["a", "e", "b"])
        #expect(statistics.topCharacters.map(\.count) == [5, 4, 3])
    }
}
