//
//  MovieStatisticsProvider.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

protocol MovieStatisticsProviding: Sendable {
    func statistics(for page: MoviePage) -> MovieStatistics
}

struct MovieStatisticsProvider: MovieStatisticsProviding {
    func statistics(for page: MoviePage) -> MovieStatistics {
        MovieStatistics(movieTitle: page.title, actors: page.actors)
    }
}

struct MovieStatistics: Equatable, Sendable {
    let movieTitle: String
    let itemCount: Int
    let topCharacters: [CharacterOccurrence]

    init(movieTitle: String, actors: [Actor]) {
        self.movieTitle = movieTitle
        itemCount = actors.count

        let names = actors.map(\.fullName).joined()
        let counts = names
            .lowercased()
            .filter { $0.isLetter }
            .reduce(into: [Character: Int]()) { result, character in
                result[character, default: 0] += 1
            }

        topCharacters = counts
            .sorted { lhs, rhs in
                lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value
            }
            .prefix(3)
            .map { CharacterOccurrence(character: $0.key, count: $0.value) }
    }
}

struct CharacterOccurrence: Equatable, Sendable {
    let character: Character
    let count: Int
}
