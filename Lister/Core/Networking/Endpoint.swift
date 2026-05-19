//
//  Endpoint.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

struct Endpoint<Response: Decodable & Sendable>: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
}
