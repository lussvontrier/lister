//
//  MovieStatisticsViewController.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import UIKit

final class MovieStatisticsViewController: UITableViewController {
    private let statistics: MovieStatistics

    init(statistics: MovieStatistics) {
        self.statistics = statistics
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        tableView.register(StatisticsValueCell.self, forCellReuseIdentifier: StatisticsValueCell.reuseIdentifier)
        tableView.register(StatisticsLetterCell.self, forCellReuseIdentifier: StatisticsLetterCell.reuseIdentifier)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : statistics.topCharacters.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : "Most common letters"
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StatisticsValueCell.reuseIdentifier,
                for: indexPath
            ) as? StatisticsValueCell else {
                return UITableViewCell()
            }

            if indexPath.row == 0 {
                cell.configure(title: "Movie", value: statistics.movieTitle)
            } else {
                cell.configure(title: "Cast count", value: "\(statistics.itemCount)")
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsLetterCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsLetterCell else {
            return UITableViewCell()
        }

        let item = statistics.topCharacters[indexPath.row]
        cell.configure(character: item.character, count: item.count)
        return cell
    }
}

private final class StatisticsValueCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    private func configureHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

private final class StatisticsLetterCell: UITableViewCell {
    private enum Layout {
        static let circleSize: CGFloat = 34
    }

    private lazy var characterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .black
        label.layer.cornerRadius = Layout.circleSize / 2
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(character: Character, count: Int) {
        characterLabel.text = String(character).uppercased()
        countLabel.text = "\(count) appearances"
    }

    private func configureHierarchy() {
        contentView.addSubview(characterLabel)
        contentView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            characterLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            characterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterLabel.widthAnchor.constraint(equalToConstant: Layout.circleSize),
            characterLabel.heightAnchor.constraint(equalTo: characterLabel.widthAnchor),

            countLabel.leadingAnchor.constraint(equalTo: characterLabel.trailingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            countLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            countLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
