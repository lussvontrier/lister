//
//  TMDBMovieModels.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct TMDBPagedResponse<Result: Decodable & Sendable>: Decodable, Sendable {
    let results: [Result]
}

struct TMDBMovieDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let voteAverage: Double?
    let backdropPath: String?
}

struct TMDBCreditsResponse: Decodable, Sendable {
    let cast: [TMDBCastMemberDTO]
}

struct TMDBCastMemberDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?
}
