//
//  ImageLoader.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit
import Combine

protocol ImageProvider {
    func loadPosterImage(urlString: String) -> AnyPublisher<UIImage?, Never>?
}

class ImageLoader: ImageProvider {

    func loadPosterImage(urlString: String) -> AnyPublisher<UIImage?, Never>? {

        if let url = URL(string: urlString) {

            let defaultImage = UIImage(named: "popcorn")
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let publisher = URLSession.DataTaskPublisher(request: request, session: .shared)
                .retry(2)
                .map(\.data)
                .map(UIImage.init)
                .replaceNil(with: defaultImage)
                .replaceError(with: defaultImage)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()

            return publisher
        }
        return nil
    }
}
