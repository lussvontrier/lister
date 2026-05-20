//
//  RemoteImageView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class RemoteImageView: UIImageView {
    private var imageTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(url: URL?, placeholderSystemName: String) {
        imageTask?.cancel()
        image = UIImage(systemName: placeholderSystemName)
        tintColor = .secondaryLabel

        guard let url else { return }

        imageTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled, let image = UIImage(data: data) else { return }
                await MainActor.run {
                    self?.tintColor = nil
                    self?.image = image
                }
            } catch {
                return
            }
        }
    }

    func cancelImageLoad() {
        imageTask?.cancel()
        imageTask = nil
    }

    private func configure() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
        backgroundColor = .tertiarySystemFill
    }
}
