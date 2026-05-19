//
//  MoviePage.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct MoviePage: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let releaseYear: String?
    let rating: Double?
    let overview: String
    let wallpaperURL: URL?
    let actors: [Actor]

    var headline: String {
        [releaseYear, formattedRating]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    private var formattedRating: String? {
        guard let rating else { return nil }
        return String(format: "%.1f TMDB", rating)
    }
}

struct Actor: Identifiable, Equatable, Sendable {
    let id: Int
    let fullName: String
    let role: String?
    let imageURL: URL?
}
