//
//  WallpaperCarouselView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct WallpaperCarouselView: View {
    let pages: [MoviePage]
    @Binding var selectedMovieID: MoviePage.ID

    var body: some View {
        TabView(selection: $selectedMovieID) {
            ForEach(pages) { page in
                AsyncRemoteImageView(url: page.wallpaperURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                    }
                .clipShape(RoundedRectangle(cornerRadius: 0))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(page.title)
                .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 320)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
