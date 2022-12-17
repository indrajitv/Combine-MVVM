//
//  TestServerMovieFetcher.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 16/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

final class TestServerMovieFetcher: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func test_getMovieList_shouldReceiveSuccess_andThreadShouldBeMain() {
        let exp = expectation(description: "Should have 1 movie as a success!")
        let sut = makeSUT(expectation: .success(jsonData: makeMovies()))

        sut.getMovieList().sink { _ in } receiveValue: { movies in

            XCTAssertEqual(Thread.current, .main)
            XCTAssertEqual(movies.count, 1)
            exp.fulfill()
        }
        .store(in: &self.subscriptions)

        wait(for: [exp], timeout: 0.05)
    }

    func test_getMovieList_shouldReceiveFailure() {

        let exp = expectation(description: "Should receive error!")
        let sut = makeSUT(expectation: .failure(error: .unknown))

        sut.getMovieList().sink { completion in

            if case .failure = completion {
                exp.fulfill()
            }
        } receiveValue: { _ in  }
            .store(in: &self.subscriptions)

        wait(for: [exp], timeout: 0.05)
    }

    func makeSUT(expectation: MockedAPIProvider.ResponseExpectation) -> ServerMovieFetcher  {
        let apiProvider = MockedAPIProvider(expectation: expectation)
        let sut = ServerMovieFetcher(apiProvider: apiProvider)
        return sut
    }

    func makeMovies() -> Data {
        let json = """
            {"results":[{"title":"foo","overview":"bar","poster_path":"https://www.google.com"}]}
            """.data(using: .utf8)!
        return json
    }
}
