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
    let wallpaperURL: URL?
    let actors: [Actor]
}

struct Actor: Identifiable, Equatable, Sendable {
    let id: Int
    let fullName: String
    let role: String?
    let imageURL: URL?
}
