//
//  MessageCell.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class MessageCell: UITableViewCell {
    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 28
    }

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: String) {
        messageLabel.text = message
    }

    private func configureHierarchy() {
        backgroundColor = .systemGroupedBackground
        selectionStyle = .none
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.verticalInset),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.verticalInset)
        ])
    }
}
