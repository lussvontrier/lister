//
//  MovieBrowserView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct MovieBrowserView: View {
    @Bindable private var viewModel: MovieBrowserViewModel

    init(viewModel: MovieBrowserViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                content

                if viewModel.statistics != nil {
                    FloatingStatisticsButton {
                        viewModel.isShowingStatistics = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.load()
            }
            .sheet(isPresented: $viewModel.isShowingStatistics) {
                if let statistics = viewModel.statistics {
                    StatisticSheetView(statistics: statistics)
                        .presentationDetents([.medium])
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()
        case .empty:
            ContentUnavailableView("No Movies", systemImage: "film")
        case .failed(let message):
            ContentUnavailableView {
                Label("Could Not Load Movies", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.load() }
                }
            }
        case .loaded(let pages):
            loadedContent(pages: pages)
        }
    }

    private func loadedContent(pages: [MoviePage]) -> some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                Color(.systemGroupedBackground)
                    .frame(height: proxy.safeAreaInsets.top)
                    .ignoresSafeArea(edges: .top)
            }
            .allowsHitTesting(false)
                .zIndex(1)

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    WallpaperCarouselView(
                        pages: pages,
                        selectedMovieID: Binding(
                            get: { viewModel.selectedPage?.id ?? pages[0].id },
                            set: { viewModel.selectMovie(withID: $0) }
                        )
                    )
                    .padding(.bottom, 8)
                    .scrollTransition(axis: .vertical) { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.96)
                            .opacity(phase.isIdentity ? 1 : 0.86)
                    }

                    Section {
                        ActorListView(actors: viewModel.filteredActors)
                    } header: {
                        SearchHeaderView(text: $viewModel.searchText)
                        .zIndex(2)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .animation(.snappy, value: viewModel.filteredActors)
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading movies")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct FloatingStatisticsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title3.weight(.semibold))
                .frame(width: 58, height: 58)
                .background(.blue.gradient, in: Circle())
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 6)
        }
        .accessibilityLabel("Show statistics")
    }
}
