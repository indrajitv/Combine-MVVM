//
//  APIManager.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation
import Combine

class APIManager: APIProvider {

    let hostPath: String = "https://api.themoviedb.org/3"
    let apiKey = "e4f9e61f6ffd66639d33d3dde7e3159b"

    private let urlSession: URLSession
    private var subscriptions = Set<AnyCancellable>()
    private var attempt: Int = 0

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func execute<T: Decodable>(apiRequest: APIRequest, value: T.Type, queue: DispatchQueue) -> AnyPublisher<T, Error> {
        return self.createPublisher(apiRequest: apiRequest)
            .handleEvents(receiveSubscription: { _ in
                self.attempt += 1
                print("API Event: Attempt \(self.attempt) started for \(apiRequest.path)...")
            }, receiveCompletion: { _ in
                print("API Event: Attempt \(self.attempt) completed for \(apiRequest.path)...")
            })
            .retry(apiRequest.attempts)
            .receive(on: queue)
            .tryMap { data, _ in

                try JSONDecoder().decode(T.self, from: data)
            }.eraseToAnyPublisher()
    }

    func execute<T: Decodable>(apiRequest: APIRequest, value: T.Type, queue: DispatchQueue) -> Future<T, CustomError> {

        return .init { [weak self] result in

            guard let self = self else { return result(.failure(.custom(description: "Instance is not alive to go ahead."))) }

            let url: URL = .init(self.hostPath, self.apiKey, apiRequest)

            let request: URLRequest = .init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: apiRequest.timeInterval)

            URLSession.DataTaskPublisher(request: request, session: self.urlSession)
                .handleEvents(receiveSubscription: { _ in
                    self.attempt += 1
                    print("API Event: Attempt \(self.attempt) started for \(apiRequest.path)...")
                }, receiveCompletion: { _ in
                    print("API Event: Attempt \(self.attempt) completed for \(apiRequest.path)...")
                })
                .retry(apiRequest.attempts)
                .receive(on: queue)
                .tryMap { data, _ in

                    try JSONDecoder().decode(T.self, from: data)
                }.sink { completion in

                    if case .failure(let error) = completion {
                        result(.failure(.custom(description: error.localizedDescription)))
                    }
                } receiveValue: { codable in

                    result(.success(codable))
                }.store(in: &self.subscriptions)
        }
    }

    private func createPublisher(apiRequest: APIRequest) -> URLSession.DataTaskPublisher {
        let url: URL = .init(self.hostPath, self.apiKey, apiRequest)
        let request: URLRequest = .init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: apiRequest.timeInterval)
        return URLSession.DataTaskPublisher(request: request, session: self.urlSession)
    }
}
