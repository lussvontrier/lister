//
//  ActorCell.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class ActorCell: UITableViewCell {
    private enum Layout {
        static let portraitSize: CGFloat = 62
        static let contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        static let textSpacing: CGFloat = 4
        static let contentSpacing: CGFloat = 14
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 2
    }

    private lazy var portraitView: RemoteImageView = {
        let view = RemoteImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Layout.portraitSize / 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
        view.layer.borderWidth = Layout.borderWidth
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = Layout.textSpacing
        textStack.alignment = .fill

        let stack = UIStackView(arrangedSubviews: [portraitView, textStack])
        stack.axis = .horizontal
        stack.spacing = Layout.contentSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        portraitView.cancelImageLoad()
    }

    func configure(with presentation: ActorRowPresentation) {
        portraitView.setImage(url: presentation.imageURL, placeholderSystemName: "person.fill")
        nameLabel.text = presentation.name
        roleLabel.text = presentation.role
        roleLabel.isHidden = presentation.role == nil
    }

    private func configureHierarchy() {
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            portraitView.widthAnchor.constraint(equalToConstant: Layout.portraitSize),
            portraitView.heightAnchor.constraint(equalTo: portraitView.widthAnchor),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.contentInset.top),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.contentInset.left),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.contentInset.right),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.contentInset.bottom)
        ])
    }

    private func configureStyle() {
        selectionStyle = .none
        backgroundColor = .systemGroupedBackground
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.layer.masksToBounds = true
    }
}
