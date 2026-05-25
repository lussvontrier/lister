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
    private typealias ActorDataSource = UITableViewDiffableDataSource<ActorListSection, MovieActorRowPresentation>
    private typealias ActorSnapshot = NSDiffableDataSourceSnapshot<ActorListSection, MovieActorRowPresentation>

    private enum Layout {
        static let messageHorizontalInset: CGFloat = 28
        static let statisticsButtonSize: CGFloat = 58
        static let statisticsButtonTrailing: CGFloat = 20
        static let statisticsButtonBottom: CGFloat = 24
        static let wallpaperHeight: CGFloat = 240
    }

    private enum ActorListSection {
        case main
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
        tableView.keyboardDismissMode = .interactive
        tableView.delegate = self
        tableView.register(ActorCell.self, forCellReuseIdentifier: ActorCell.reuseIdentifier)
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
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

    private lazy var searchHeaderView: SearchHeaderView = {
        let view = SearchHeaderView()
        view.onTextChange = { [weak self] text in
            self?.viewModel.updateSearchText(text)
        }
        view.onReturn = { [weak self] in
            self?.view.endEditing(true)
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

    private lazy var dataSource: ActorDataSource = {
        let dataSource = ActorDataSource(tableView: tableView) { tableView, indexPath, row in
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
        dataSource.defaultRowAnimation = .bottom
        return dataSource
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
        configureHierarchy()
        configureDataSource()
        bindViewModel()
        bindKeyboard()

        Task { await viewModel.load() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderHeight()
    }

    private func configureHierarchy() {
        view.backgroundColor = .systemGroupedBackground

        [tableView, loadingView, messageLabel, statisticsButton].forEach(view.addSubview)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    private func bindKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.adjustInsetsForKeyboard(notification)
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
            let previousContent = contentPresentation
            contentPresentation = content
            tableView.isHidden = false
            messageLabel.isHidden = true
            statisticsButton.isHidden = false
            renderContent(content, previousContent: previousContent)
        }
    }

    private func renderContent(
        _ content: MovieBrowserContentPresentation,
        previousContent: MovieBrowserContentPresentation?
    ) {
        let didChangeCarousel = previousContent?.pages != content.pages
            || previousContent?.selectedMovieIndex != content.selectedMovieIndex

        if didChangeCarousel {
            wallpaperView.configure(pages: content.pages, selectedIndex: content.selectedMovieIndex)
        }

        searchHeaderView.configure(with: content.actorSection.header)
        applyActorRows(content.actorSection.rows, animatingDifferences: previousContent != nil)
    }

    private func configureDataSource() {
        _ = dataSource
    }

    private func applyActorRows(_ rows: [MovieActorRowPresentation], animatingDifferences: Bool) {
        var snapshot = ActorSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(rows, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func renderMessage(_ message: String) {
        contentPresentation = nil
        applyActorRows([], animatingDifferences: false)
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
        view.endEditing(true)
        let viewController = MovieStatisticsViewController(statistics: statistics)
        let navigationController = UINavigationController(rootViewController: viewController)
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }

    @objc private func dismissKeyboard() {
        searchHeaderView.endEditing()
    }

    private func adjustInsetsForKeyboard(_ notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        let keyboardOverlap = max(0, view.bounds.maxY - convertedFrame.minY)
        let bottomInset = keyboardOverlap > 0 ? keyboardOverlap - view.safeAreaInsets.bottom : 0

        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
}

extension MovieBrowserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        contentPresentation?.actorSection.headerHeight ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerPresentation = contentPresentation?.actorSection.header else {
            return nil
        }

        searchHeaderView.configure(with: headerPresentation)
        return searchHeaderView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        contentPresentation?.actorSection.estimatedRowHeight ?? UITableView.automaticDimension
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
