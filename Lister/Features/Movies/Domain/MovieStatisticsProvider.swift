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
    private enum Constants {
        static let topCharacterLimit = 3
    }

    func statistics(for page: MoviePage) -> MovieStatistics {
        MovieStatistics(
            movieTitle: page.title,
            itemCount: page.actors.count,
            topCharacters: topCharacters(from: page.actors)
        )
    }

    private func topCharacters(from actors: [Actor]) -> [CharacterOccurrence] {
        characterCounts(from: actors)
            .sorted(by: sortByFrequencyThenAlphabetically)
            .prefix(Constants.topCharacterLimit)
            .map { CharacterOccurrence(character: $0.key, count: $0.value) }
    }

    private func characterCounts(from actors: [Actor]) -> [Character: Int] {
        actorNameCharacters(from: actors)
            .reduce(into: [Character: Int]()) { counts, character in
                counts[character, default: 0] += 1
            }
    }

    private func actorNameCharacters(from actors: [Actor]) -> [Character] {
        actors
            .map(\.fullName)
            .joined()
            .lowercased()
            .filter(\.isLetter)
    }

    private func sortByFrequencyThenAlphabetically(
        lhs: Dictionary<Character, Int>.Element,
        rhs: Dictionary<Character, Int>.Element
    ) -> Bool {
        lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value
    }
}

struct MovieStatistics: Equatable, Sendable {
    let movieTitle: String
    let itemCount: Int
    let topCharacters: [CharacterOccurrence]
}

struct CharacterOccurrence: Equatable, Sendable {
    let character: Character
    let count: Int
}
