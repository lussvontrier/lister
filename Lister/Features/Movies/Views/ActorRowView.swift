//
//  ActorRowView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct ActorRowView: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 8
    }

    let actor: Actor

    var body: some View {
        HStack(spacing: 14) {
            AsyncRemoteImageView(url: actor.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.tertiarySystemFill)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 62, height: 62)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.9), lineWidth: 2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(actor.fullName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let role = actor.role {
                    Text(role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}
