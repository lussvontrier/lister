//
//  ListerApp.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

@main
struct ListerApp: App {
    private let environmentResult = Result {
        try AppEnvironment.live()
    }

    var body: some Scene {
        WindowGroup {
            switch environmentResult {
            case .success(let environment):
                MovieBrowserView(
                    viewModel: MovieBrowserViewModel(
                        repository: environment.movieRepository,
                        statisticsProvider: environment.movieStatisticsProvider
                    )
                )
            case .failure(let error):
                ContentUnavailableView {
                    Label("Configuration Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}
