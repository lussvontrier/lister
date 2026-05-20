//
//  WallpaperCarouselView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class WallpaperCarouselView: UIView {
    private enum Layout {
        static let pageControlBottom: CGFloat = 10
    }

    var onPageChange: ((Int) -> Void)?

    private var pages: [MoviePage] = []

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemGroupedBackground
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WallpaperCell.self, forCellWithReuseIdentifier: WallpaperCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.42)
        control.backgroundStyle = .minimal
        control.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(pages: [MoviePage], selectedIndex: Int) {
        self.pages = pages
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = selectedIndex
        pageControl.isHidden = pages.count < 2
        collectionView.reloadData()

        guard pages.indices.contains(selectedIndex) else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }

    private func configureHierarchy() {
        addSubview(collectionView)
        addSubview(pageControl)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.pageControlBottom)
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }

    @objc private func pageControlDidChange() {
        let index = pageControl.currentPage
        guard pages.indices.contains(index) else { return }

        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        onPageChange?(index)
    }
}

extension WallpaperCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WallpaperCell.reuseIdentifier,
            for: indexPath
        ) as? WallpaperCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: pages[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyCurrentPage()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyCurrentPage()
        }
    }

    private func notifyCurrentPage() {
        guard collectionView.bounds.width > 0 else { return }
        let index = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        guard pages.indices.contains(index) else { return }
        pageControl.currentPage = index
        onPageChange?(index)
    }
}

private final class WallpaperCell: UICollectionViewCell {
    private lazy var imageView: RemoteImageView = {
        let view = RemoteImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
    }

    func configure(with page: MoviePage) {
        imageView.setImage(url: page.wallpaperURL, placeholderSystemName: "film")
    }

    private func configureHierarchy() {
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
