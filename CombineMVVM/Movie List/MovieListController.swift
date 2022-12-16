//
//  MovieListController.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit
import Combine

final class MovieListController: UIViewController {

    private let viewModel: MovieListViewModel
    private var subscriptions = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieListCell.self, forCellReuseIdentifier: MovieListCell.cellID)
        table.delegate = self
        return table
    }()

    typealias DatasourceType = UITableViewDiffableDataSource<AnyHashable, MovieListCellViewModel>

    private lazy var tableDatasource: DatasourceType = {
        let tableDatasource: DatasourceType = .init(tableView: self.tableView) { tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieListCell.cellID, for: indexPath) as! MovieListCell
            cell.configureCell(from: viewModel)
            return cell
        }
        tableDatasource.defaultRowAnimation = .top
        return tableDatasource
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = self.viewModel.searchBarPlaceholder
        return searchBar
    }()

    init(viewMode: MovieListViewModel) {
        self.viewModel = viewMode

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
        self.loadMovies()

        self.subscribePublishers()
    }

    private func setUpViews() {
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    private func loadMovies() {
        self.viewModel.getMovieList()
            .sink { [unowned self] completion in

                if case .failure(let error) = completion {
                    Alert.show(on: self, message: error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }

    private func loadDatasource(movies: [MovieListCellViewModel]) {
        var snap = self.tableDatasource.snapshot()

        if snap.numberOfSections == 0 {
            snap.appendSections([.init("")])
        }

        snap.appendItems(movies)
        self.tableDatasource.apply(snap, animatingDifferences: true)
    }

    private func deleteDatasource(item movie: MovieListCellViewModel) {
        var snap = self.tableDatasource.snapshot()
        snap.deleteItems([movie])
        self.tableDatasource.apply(snap, animatingDifferences: true)
    }

    private func deleteAllItemsFromDatasource() {
        var snap = self.tableDatasource.snapshot()
        snap.deleteAllItems()
        self.tableDatasource.apply(snap)
    }

    private func subscribePublishers() {
        self.viewModel.$navigationTitle
            .map{ $0 }
            .assign(to: \.title, on: self)
            .store(in: &self.subscriptions)
        
        self.viewModel.$movieListCellViewModels
            .sink { [unowned self] viewModels in
                self.loadDatasource(movies: viewModels)
            }
            .store(in: &self.subscriptions)

        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification,
                                             object: self.searchBar.searchTextField)
        .debounce(for: 0.2, scheduler: DispatchQueue.main) // This will stop calling API on each typing.
        .compactMap({ ($0.object as? UISearchTextField)?.text }) // We are only interested in text.
        .sink { [weak self] text in
            self?.deleteAllItemsFromDatasource()
            self?.viewModel.filterCurrentMovies(with: text)
        }
        .store(in: &self.subscriptions)
    }
}

extension MovieListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        return .init(actions: [.init(style: .destructive,
                                     title: self.viewModel.tableSwipeDeleteActionText,
                                     handler: { [weak self] _, _, completion in
            if let item = self?.viewModel.deleteMovieAt(at: indexPath.row) {
                self?.deleteDatasource(item: item)
            }
            completion(true)
        })])
    }
}
