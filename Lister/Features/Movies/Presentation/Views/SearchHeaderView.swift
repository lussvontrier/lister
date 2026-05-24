//
//  SearchHeaderView.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class SearchHeaderView: UIView {
    private enum Layout {
        static let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 10, right: 16)
        static let fieldHeight: CGFloat = 42
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let iconContainerWidth: CGFloat = 44
        static let iconLeadingInset: CGFloat = 12
        static let iconSize: CGFloat = 22
    }

    var onTextChange: ((String) -> Void)?
    var onReturn: (() -> Void)?

    private lazy var fieldBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.masksToBounds = true
        view.layer.borderWidth = Layout.borderWidth
        return view
    }()

    private lazy var searchIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var searchIconContainerView: UIView = {
        let view = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Layout.iconContainerWidth,
                height: Layout.fieldHeight
            )
        )
        searchIconView.frame = CGRect(
            x: Layout.iconLeadingInset,
            y: 0,
            width: Layout.iconSize,
            height: Layout.fieldHeight
        )
        view.addSubview(searchIconView)
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.leftView = searchIconContainerView
        textField.leftViewMode = .always
        textField.placeholder = "Search actors"
        textField.returnKeyType = .search
        textField.textColor = .label
        textField.tintColor = .label
        textField.backgroundColor = .clear
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureStyle()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with presentation: SearchHeaderPresentation) {
        guard textField.text != presentation.text else { return }
        textField.text = presentation.text
    }

    func endEditing() {
        textField.resignFirstResponder()
    }

    private func configureHierarchy() {
        addSubview(fieldBackgroundView)
        fieldBackgroundView.addSubview(textField)

        NSLayoutConstraint.activate([
            fieldBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.contentInset.top),
            fieldBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentInset.left),
            fieldBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentInset.right),
            fieldBackgroundView.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),

            textField.topAnchor.constraint(equalTo: fieldBackgroundView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: fieldBackgroundView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: fieldBackgroundView.trailingAnchor, constant: -12),
            textField.bottomAnchor.constraint(equalTo: fieldBackgroundView.bottomAnchor)
        ])
    }

    private func configureStyle() {
        isOpaque = true
        backgroundColor = .systemGroupedBackground
        fieldBackgroundView.layer.borderColor = UIColor.separator.withAlphaComponent(0.08).cgColor
    }

    @objc private func textFieldDidChange() {
        onTextChange?(textField.text ?? .empty)
    }
}

extension SearchHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onReturn?()
        return true
    }
}
