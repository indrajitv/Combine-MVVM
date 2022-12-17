//
//  MockedMovieProvider.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 17/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

enum ResponseExpectation {
    case success
    case successWithEmptyVieWModels
    case failure
}

final class MockedMovieProvider: MovieProvider {

    let expectation: ResponseExpectation

    init(expectation: ResponseExpectation) {
        self.expectation = expectation
    }

    func getMovieList() -> Future<[Movie], CustomError> {
        return .init { result in

            switch self.expectation {
                case .success:
                    let movies = self.createDummyMovies()
                    result(.success(movies))
                case .successWithEmptyVieWModels:
                    result(.success([]))
                case .failure:
                    result(.failure(.unknown))
            }
        }
    }

    func createDummyMovies() -> [Movie] {
        return (1...10).map{ val in
            return Movie.init(title: "\(val) Title", overview: "\(val) OverView", posterPath: "https://www.\(val)whoAmI.com")
        }
    }
}

final class MockedAPIProvider: APIProvider {
    var apiKey: String = "dummy/"
    var hostPath: String = "dummy_host/"

    let expectedResponse: ResponseExpectation

    enum ResponseExpectation {
        case success(jsonData: Data, delay: TimeInterval? = nil)
        case failure(error: CustomError)
    }

    init(expectation: ResponseExpectation) {
        self.expectedResponse = expectation
    }

    func execute<T>(apiRequest: CombineMVVM.APIRequest, value: T.Type, queue: DispatchQueue) -> Future<T, CombineMVVM.CustomError> where T : Decodable {
        return .init { result in
            queue.async {
                if case .success(jsonData: let data, let delay) = self.expectedResponse {

                    let decoded = try! JSONDecoder().decode(value.self, from: data)
                    if let delay = delay {
                        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                            result(.success(decoded))
                        }
                    } else {
                        result(.success(decoded))
                    }
                } else if case .failure(let error) = self.expectedResponse {

                    result(.failure(error))
                }
            }
        }
    }

    func execute<T>(apiRequest: CombineMVVM.APIRequest, value: T.Type, queue: DispatchQueue) -> AnyPublisher<T, Error> where T : Decodable {
        if case .success(jsonData: let data, let delay) = self.expectedResponse {

            let decoded = try! JSONDecoder().decode(value.self, from: data)

            if let delay = delay {
                return Result.success(decoded).publisher.receive(on: queue).delay(for: RunLoop.SchedulerTimeType.Stride(delay), scheduler: RunLoop.main).eraseToAnyPublisher()
            } else {
                return Result.success(decoded).publisher.receive(on: queue).eraseToAnyPublisher()
            }
        } else if case .failure(let error) = self.expectedResponse {

            return Result.failure(error).publisher.receive(on: queue).eraseToAnyPublisher()
        } else {
            fatalError()
        }
    }
}
