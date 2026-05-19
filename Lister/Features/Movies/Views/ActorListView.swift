//
//  ActorListView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct ActorListView: View {
    let actors: [Actor]

    var body: some View {
        LazyVStack(spacing: 10) {
            if actors.isEmpty {
                ContentUnavailableView("No Actors", systemImage: "person.crop.circle.badge.questionmark")
                    .padding(.top, 48)
            } else {
                ForEach(actors) { actor in
                    ActorRowView(actor: actor)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 24)
    }
}
