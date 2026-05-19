//
//  StatisticSheetView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct StatisticSheetView: View {
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
                                .frame(width: 34, height: 34)
                                .background(Color(.secondarySystemGroupedBackground), in: Circle())

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
