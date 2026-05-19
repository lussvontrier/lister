//
//  MovieBrowserViewModel.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class MovieBrowserViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([MoviePage])
        case empty
        case failed(String)
    }

    var viewState: ViewState = .idle
    var selectedMovieID: MoviePage.ID?
    var searchText: String = .empty
    var isShowingStatistics = false

    private let repository: MovieRepository
    private let statisticsProvider: MovieStatisticsProviding

    init(
        repository: MovieRepository,
        statisticsProvider: MovieStatisticsProviding
    ) {
        self.repository = repository
        self.statisticsProvider = statisticsProvider
    }

    var pages: [MoviePage] {
        guard case let .loaded(pages) = viewState else { return [] }
        return pages
    }

    var selectedPage: MoviePage? {
        guard !pages.isEmpty else { return nil }
        return pages.first { $0.id == selectedMovieID } ?? pages[0]
    }

    var filteredActors: [Actor] {
        guard let selectedPage else { return [] }
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return selectedPage.actors }

        return selectedPage.actors.filter {
            $0.fullName.localizedCaseInsensitiveContains(trimmedSearch)
            || ($0.role?.localizedCaseInsensitiveContains(trimmedSearch) ?? false)
        }
    }

    var statistics: MovieStatistics? {
        guard let selectedPage else { return nil }
        return statisticsProvider.statistics(for: selectedPage)
    }

    func load() async {
        guard viewState != .loading else { return }
        viewState = .loading

        do {
            let pages = try await repository.fetchMoviePages()
            if pages.isEmpty {
                viewState = .empty
            } else {
                selectedMovieID = pages[0].id
                viewState = .loaded(pages)
            }
        } catch {
            viewState = .failed(error.localizedDescription)
        }
    }

    func selectMovie(withID id: MoviePage.ID) {
        selectedMovieID = id
        searchText = .empty
    }
}
