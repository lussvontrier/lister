//
//  RemoteImageView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class RemoteImageView: UIImageView {
    private static let imageCache = NSCache<NSURL, UIImage>()

    private var imageTask: Task<Void, Never>?
    private var currentURL: URL?

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
        if currentURL == url, image != nil {
            return
        }

        imageTask?.cancel()
        currentURL = url

        if let url, let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
            tintColor = nil
            image = cachedImage
            return
        }

        image = UIImage(systemName: placeholderSystemName)
        tintColor = .secondaryLabel

        guard let url else { return }

        imageTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled, let image = UIImage(data: data) else { return }
                await MainActor.run {
                    Self.imageCache.setObject(image, forKey: url as NSURL)
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
        currentURL = nil
    }

    private func configure() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
        backgroundColor = .tertiarySystemFill
    }
}
