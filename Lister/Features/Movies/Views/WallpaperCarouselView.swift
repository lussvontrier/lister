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
                ZStack(alignment: .bottomLeading) {
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

                    LinearGradient(
                        colors: [.black.opacity(0.08), .black.opacity(0.18), .black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        if !page.headline.isEmpty {
                            Text(page.headline)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.82))
                                .textCase(.uppercase)
                        }

                        Text(page.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        if !page.overview.isEmpty {
                            Text(page.overview)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.84))
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
                .clipShape(RoundedRectangle(cornerRadius: 0))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(page.title)
                .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 320)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
