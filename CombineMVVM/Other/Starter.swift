//
//  Starter.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit

class Starter {
    func start(on window: UIWindow) {
        let viewModel = MovieListViewModel(movieProvider: ServerMovieFetcher(apiProvider: APIManager()))
        let navigationController: UINavigationController = .init(rootViewController: MovieListController(viewMode: viewModel))
        window.rootViewController = navigationController
    }
}
