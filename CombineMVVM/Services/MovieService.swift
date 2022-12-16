//
//  MovieProvider.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Combine

protocol MovieProvider {
    func getMovieList() -> Future<[Movie], CustomError>
}

class ServerMovieFetcher: MovieProvider {

    private let apiProvider: APIProvider
    private var subscriptions = Set<AnyCancellable>()

    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }

    func getMovieList() -> Future<[Movie], CustomError> {

        return .init { [unowned self] result in
            
            self.apiProvider.execute(apiRequest: .init(path: "/movie/top_rated", type: .get), value: Page.self, queue: .main)
                .sink { complete in
                    if case .failure(let error) = complete {
                        result(.failure(error))
                    }
                } receiveValue: { page in
                    result(.success(page.results))
                }
                .store(in: &self.subscriptions)
        }
    }
}
