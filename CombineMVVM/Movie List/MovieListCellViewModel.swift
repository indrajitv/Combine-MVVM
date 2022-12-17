//
//  MovieListCellViewModel.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit
import Combine

final class MovieListCellViewModel {

    private var id: UUID = .init() // For diffable datasource.

    private let movie: Movie
    private let imageProvider: ImageProvider

    @Published
    var title: String

    @Published
    var description: String

    init(movie: Movie, imageProvider: ImageProvider = ImageLoader()) {
        self.movie = movie
        self.imageProvider = imageProvider
        self.title = self.movie.title
        self.description = self.movie.overview

        /* Test realtime value changes. It's fun.
         Timer.scheduledTimer(withTimeInterval: [1, 2, 3, 4].randomElement()!, repeats: true) { _ in
         self.title = self.movie.title + " " + "\(Date().description)".components(separatedBy: ":").last!
         } */
    }

    func loadPosterImage() -> AnyPublisher<UIImage?, Never>? {
        if let urlString = self.movie.posterPath {

            let fullPath = "https://image.tmdb.org/t/p/w185/"+urlString
            let publisher = self.imageProvider.loadPosterImage(urlString: fullPath)
            return publisher
        }
        return nil
    }
}

extension MovieListCellViewModel: Hashable { // For diffable datasource.
    static func == (lhs: MovieListCellViewModel, rhs: MovieListCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
