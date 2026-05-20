//
//  MovieBrowserViewController.swift
//  Lister
//
//  Created by Lusine Magauzyan on 20.05.26.
//  Copyright © 2026 Lusine Magauzyan. All rights reserved.
//

import Combine
import UIKit

final class MovieBrowserViewController: UIViewController {
    private enum Layout {
        static let messageHorizontalInset: CGFloat = 28
        static let statisticsButtonSize: CGFloat = 58
        static let statisticsButtonTrailing: CGFloat = 20
        static let statisticsButtonBottom: CGFloat = 24
        static let wallpaperHeight: CGFloat = 320
    }

    private let viewModel: MovieBrowserViewModel
    private var contentPresentation: MovieBrowserContentPresentation?
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ActorCell.self, forCellReuseIdentifier: ActorCell.reuseIdentifier)
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchHeaderView.reuseIdentifier)
        tableView.tableHeaderView = wallpaperView
        return tableView
    }()

    private lazy var wallpaperView: WallpaperCarouselView = {
        let view = WallpaperCarouselView()
        view.onPageChange = { [weak self] index in
            self?.viewModel.selectMovie(at: index)
        }
        return view
    }()

    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var statisticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Layout.statisticsButtonSize / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.22
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.addTarget(self, action: #selector(showStatistics), for: .touchUpInside)
        button.accessibilityLabel = "Show statistics"
        button.isHidden = true
        return button
    }()

    init(viewModel: MovieBrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cast"
        configureHierarchy()
        bindViewModel()

        Task { await viewModel.load() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderHeight()
    }

    private func configureHierarchy() {
        view.backgroundColor = .systemGroupedBackground

        [tableView, loadingView, messageLabel, statisticsButton].forEach(view.addSubview)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.messageHorizontalInset),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.messageHorizontalInset),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statisticsButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Layout.statisticsButtonTrailing
            ),
            statisticsButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.statisticsButtonBottom
            ),
            statisticsButton.widthAnchor.constraint(equalToConstant: Layout.statisticsButtonSize),
            statisticsButton.heightAnchor.constraint(equalTo: statisticsButton.widthAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$presentation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] presentation in
                self?.render(presentation)
            }
            .store(in: &cancellables)
    }

    private func render(_ presentation: MovieBrowserPresentation) {
        switch presentation {
        case .loading:
            contentPresentation = nil
            tableView.isHidden = true
            statisticsButton.isHidden = true
            messageLabel.isHidden = true
            loadingView.startAnimating()
        case .empty:
            renderMessage("No movies")
        case .failed(let message):
            renderMessage(message)
        case .content(let content):
            loadingView.stopAnimating()
            contentPresentation = content
            tableView.isHidden = false
            messageLabel.isHidden = true
            statisticsButton.isHidden = false
            wallpaperView.configure(pages: content.pages, selectedIndex: content.selectedMovieIndex)
            tableView.reloadData()
        }
    }

    private func renderMessage(_ message: String) {
        contentPresentation = nil
        loadingView.stopAnimating()
        tableView.isHidden = true
        statisticsButton.isHidden = true
        messageLabel.isHidden = false
        messageLabel.text = message
    }

    private func updateTableHeaderHeight() {
        guard tableView.tableHeaderView === wallpaperView else { return }
        if wallpaperView.frame.height != Layout.wallpaperHeight || wallpaperView.frame.width != tableView.bounds.width {
            wallpaperView.frame = CGRect(
                x: 0,
                y: 0,
                width: tableView.bounds.width,
                height: Layout.wallpaperHeight
            )
            tableView.tableHeaderView = wallpaperView
        }
    }

    @objc private func showStatistics() {
        guard let statistics = contentPresentation?.statistics else { return }
        let viewController = MovieStatisticsViewController(statistics: statistics)
        let navigationController = UINavigationController(rootViewController: viewController)
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }
}

extension MovieBrowserViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        contentPresentation == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentPresentation?.actorSection.rows.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = contentPresentation?.actorSection.rows[indexPath.row] else {
            return UITableViewCell()
        }

        switch row {
        case .actor(let actor):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ActorCell.reuseIdentifier,
                for: indexPath
            ) as? ActorCell else {
                return UITableViewCell()
            }

            cell.configure(with: actor)
            return cell
        case .message(let message):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MessageCell.reuseIdentifier,
                for: indexPath
            ) as? MessageCell else {
                return UITableViewCell()
            }

            cell.configure(message: message)
            return cell
        }
    }
}

extension MovieBrowserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        contentPresentation?.actorSection.headerHeight ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerPresentation = contentPresentation?.actorSection.header,
            let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: SearchHeaderView.reuseIdentifier
            ) as? SearchHeaderView
        else {
            return nil
        }

        header.configure(with: headerPresentation)
        header.onSearchTextChange = { [weak self] text in
            self?.viewModel.updateSearchText(text)
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        contentPresentation?.actorSection.estimatedRowHeight ?? UITableView.automaticDimension
    }
}
