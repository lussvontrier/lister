//
//  Array+Limited.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Foundation

extension Array {
    func limited(to limit: Int?) -> [Element] {
        guard let limit else { return self }
        return Array(prefix(Swift.max(0, limit)))
    }
}
