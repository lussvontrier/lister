//
//  MovieBrowserViewModel.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Combine
import CoreGraphics
import Foundation

@MainActor
final class MovieBrowserViewModel {
    @Published private(set) var presentation: MovieBrowserPresentation = .loading

    private var pages: [MoviePage] = []
    private var selectedMovieID: MoviePage.ID?
    private var searchText: String = .empty

    private let repository: MovieRepository
    private let statisticsProvider: MovieStatisticsProviding

    init(repository: MovieRepository, statisticsProvider: MovieStatisticsProviding) {
        self.repository = repository
        self.statisticsProvider = statisticsProvider
    }

    func load() async {
        presentation = .loading

        do {
            let pages = try await repository.fetchMoviePages()
            self.pages = pages

            guard let firstPage = pages.first else {
                presentation = .empty
                return
            }

            selectedMovieID = firstPage.id
            publishContent()
        } catch {
            presentation = .failed(error.localizedDescription)
        }
    }

    func selectMovie(at index: Int) {
        guard pages.indices.contains(index) else { return }
        selectedMovieID = pages[index].id
        searchText = .empty
        publishContent()
    }

    func updateSearchText(_ text: String) {
        searchText = text
        publishContent()
    }

    private func publishContent() {
        guard let selectedPage else {
            presentation = .empty
            return
        }

        let actors = filteredActors.map(ActorRowPresentation.init(actor:))
        let rows = actors.isEmpty ? [.message(emptyActorMessage)] : actors.map(MovieActorRowPresentation.actor)
        let section = MovieActorSectionPresentation(
            header: SearchHeaderPresentation(text: searchText),
            rows: rows
        )

        presentation = .content(
            MovieBrowserContentPresentation(
                pages: pages,
                selectedMovieIndex: selectedMovieIndex,
                actorSection: section,
                statistics: statisticsProvider.statistics(for: selectedPage)
            )
        )
    }

    private var selectedPage: MoviePage? {
        guard !pages.isEmpty else { return nil }
        return pages.first { $0.id == selectedMovieID } ?? pages[0]
    }

    private var selectedMovieIndex: Int {
        guard let selectedMovieID else { return 0 }
        return pages.firstIndex { $0.id == selectedMovieID } ?? 0
    }

    private var filteredActors: [Actor] {
        guard let selectedPage else { return [] }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return selectedPage.actors }

        return selectedPage.actors.filter {
            $0.fullName.localizedCaseInsensitiveContains(query)
            || ($0.role?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    private var emptyActorMessage: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No cast available" : "No matching cast"
    }
}

enum MovieBrowserPresentation: Equatable {
    case loading
    case empty
    case failed(String)
    case content(MovieBrowserContentPresentation)
}

struct MovieBrowserContentPresentation: Equatable {
    let pages: [MoviePage]
    let selectedMovieIndex: Int
    let actorSection: MovieActorSectionPresentation
    let statistics: MovieStatistics
}

struct MovieActorSectionPresentation: Equatable {
    let header: SearchHeaderPresentation
    let rows: [MovieActorRowPresentation]
    let headerHeight: CGFloat = 60
    let estimatedRowHeight: CGFloat = 88
}

struct SearchHeaderPresentation: Equatable {
    let text: String
}

struct ActorRowPresentation: Hashable {
    let id: Actor.ID
    let name: String
    let role: String?
    let imageURL: URL?

    init(actor: Actor) {
        id = actor.id
        name = actor.fullName
        role = actor.role
        imageURL = actor.imageURL
    }
}

enum MovieActorRowPresentation: Hashable {
    case actor(ActorRowPresentation)
    case message(String)
}
