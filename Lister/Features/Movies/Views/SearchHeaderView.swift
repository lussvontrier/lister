//
//  SearchHeaderView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import SwiftUI

struct SearchHeaderView: View {
    private enum Constants {
        static let horizontalInset: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let height: CGFloat = 42
    }

    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(
                text: $text,
                prompt: Text("Search actors").foregroundStyle(.secondary)
            ) {
                EmptyView()
            }
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .foregroundStyle(.primary)
            .tint(.primary)

            if !text.isEmpty {
                Button {
                    text = .empty
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: Constants.height)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.horizontal, Constants.horizontalInset)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
