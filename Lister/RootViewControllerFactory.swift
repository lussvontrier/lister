//
//  RootViewControllerFactory.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

enum RootViewControllerFactory {
    @MainActor
    static func make() -> UIViewController {
        do {
            let environment = try AppEnvironment.live()

            let viewModel = MovieBrowserViewModel(
                repository: environment.movieRepository,
                statisticsProvider: environment.movieStatisticsProvider
            )

            return MovieBrowserViewController(viewModel: viewModel)
        } catch {
            fatalError("Failed to create app environment: \(error)")
        }
    }
}
