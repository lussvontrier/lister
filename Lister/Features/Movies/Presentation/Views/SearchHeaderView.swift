//
//  SearchHeaderView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class SearchHeaderView: UITableViewHeaderFooterView {
    private enum Layout {
        static let contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        static let spacing: CGFloat = 8
    }

    var onSearchTextChange: ((String) -> Void)?

    private lazy var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = "Search actors"
        field.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
        return field
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchField, countLabel])
        stack.axis = .vertical
        stack.spacing = Layout.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        contentView.backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with presentation: SearchHeaderPresentation) {
        if searchField.text != presentation.text {
            searchField.text = presentation.text
        }
        countLabel.text = presentation.countText
    }

    private func configureHierarchy() {
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.contentInset.top),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.contentInset.left),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.contentInset.right),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.contentInset.bottom)
        ])
    }

    @objc private func searchTextDidChange() {
        onSearchTextChange?(searchField.text ?? .empty)
    }
}
