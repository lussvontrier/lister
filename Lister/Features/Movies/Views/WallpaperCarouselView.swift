//
//  WallpaperCarouselView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct WallpaperCarouselView: View {
    private enum Constants {
        static let horizontalInset: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let height: CGFloat = 240
    }

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
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(page.title)
                .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: Constants.height)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.horizontal, Constants.horizontalInset)
    }
}
