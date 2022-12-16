//
//  MoviewListViewModel.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Combine

final class MovieListViewModel {

    private let movieProvider: MovieProvider

    private var subscriptions = Set<AnyCancellable>()

    @Published
    private(set) var navigationTitle: String = "Movies"

    @Published
    private(set) var movieListCellViewModels: [MovieListCellViewModel] = []

    private var reservedMovieListCellViewModels: [MovieListCellViewModel]?

    let searchBarPlaceholder: String = "Search"

    let tableSwipeDeleteActionText: String = "Delete"

    init(movieProvider: MovieProvider) {
        self.movieProvider = movieProvider
    }

    func getMovieList() -> Future<[MovieListCellViewModel], CustomError> {
        return .init { [unowned self] result in
            self.movieProvider.getMovieList().sink(receiveCompletion: { completion in

                if case .failure(let error) = completion {
                    result(.failure(error))
                }
            }, receiveValue: { [unowned self] movies in
                
                let viewModels = movies.map{ MovieListCellViewModel(movie: $0) }
                self.movieListCellViewModels = viewModels
                result(.success(viewModels))
            })
            .store(in: &self.subscriptions)
        }
    }


    @discardableResult
    func filterCurrentMovies(with text: String) -> [MovieListCellViewModel] {
        if self.reservedMovieListCellViewModels == nil {
            self.reservedMovieListCellViewModels = self.movieListCellViewModels
        }

        if text == "" {
            self.movieListCellViewModels = self.reservedMovieListCellViewModels ?? []
            self.reservedMovieListCellViewModels = nil
        } else {
            self.movieListCellViewModels = self.reservedMovieListCellViewModels?.filter({ $0.title.lowercased().contains(text.lowercased()) }) ?? []
        }
        return self.movieListCellViewModels
    }

    func deleteMovieAt(at index : Int) -> MovieListCellViewModel {
        if var reserved = self.reservedMovieListCellViewModels, reserved.count > index {
            reserved.remove(at: index)
        }

        var item: MovieListCellViewModel!
        if self.movieListCellViewModels.count > index {
            item = self.movieListCellViewModels.remove(at: index)
        }
        
        return item
    }
}
