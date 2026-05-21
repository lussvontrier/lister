//
//  AsyncRemoteImageView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct AsyncRemoteImageView<ImageContent: View, Placeholder: View>: View {
    let url: URL?
    let image: (Image) -> ImageContent
    let placeholder: () -> Placeholder

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let loadedImage):
                image(loadedImage)
            case .failure, .empty:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}
