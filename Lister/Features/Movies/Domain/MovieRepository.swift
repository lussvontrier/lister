//
//  MovieRepository.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

protocol MovieRepository: Sendable {
    func fetchMoviePages() async throws -> [MoviePage]
}
