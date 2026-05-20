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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSheet)
        )
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsValueCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsValueCell else {
            return UITableViewCell()
        }

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Movie"
                cell.detailTextLabel?.text = statistics.movieTitle
            } else {
                cell.textLabel?.text = "Cast count"
                cell.detailTextLabel?.text = "\(statistics.itemCount)"
            }
        } else {
            let item = statistics.topCharacters[indexPath.row]
            cell.textLabel?.text = String(item.character).uppercased()
            cell.detailTextLabel?.text = "\(item.count) appearances"
        }

        return cell
    }

    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
}

private final class StatisticsValueCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
