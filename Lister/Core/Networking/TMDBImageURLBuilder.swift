//
//  TMDBImageURLBuilder.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

protocol ImageURLBuilding: Sendable {
    func url(for path: String?, size: TMDBImageSize) -> URL?
}

struct TMDBImageURLBuilder: ImageURLBuilding {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func url(for path: String?, size: TMDBImageSize) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return baseURL
            .appending(path: size.rawValue)
            .appending(path: path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
}

enum TMDBImageSize: String, Sendable {
    case backdrop = "w780"
    case profile = "w185"
}
