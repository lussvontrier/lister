//
//  StatisticSheetView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct StatisticSheetView: View {
    private enum Constants {
        static let letterBackground = Color.black
        static let letterForeground = Color.white
    }

    let statistics: MovieStatistics

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Movie", value: statistics.movieTitle)
                    LabeledContent("Cast count", value: "\(statistics.itemCount)")
                }

                Section("Most common letters") {
                    ForEach(statistics.topCharacters, id: \.character) { item in
                        HStack {
                            Text(String(item.character).uppercased())
                                .font(.headline)
                                .foregroundStyle(Constants.letterForeground)
                                .frame(width: 34, height: 34)
                                .background(Constants.letterBackground, in: Circle())

                            Text("\(item.count) appearances")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
