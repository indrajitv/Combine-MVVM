//
//  TestMovieListCellViewModel.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 17/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

final class TestMovieListCellViewModel: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func test_initShouldInitialiseAllNeededConstants() { // Because someone can make a let to var.
        let sut = makeSUT(expectation: .success)

        XCTAssertEqual(sut.title, "A title")
        XCTAssertEqual(sut.description, "An overview")
    }

    func test_loadPosterImage_imageShouldBeNil_whileURLIsInvalid() {
        let sut = makeSUT(expectation: .failure, urlString: "wrongURL")

        sut.loadPosterImage()?.sink(receiveValue: { XCTAssertNil($0) }).store(in: &self.subscriptions)
    }

    func test_loadPosterImage_imageShouldNotBeNil_whileURLIsValid() {
        let sut = makeSUT(expectation: .success, urlString: "wrongURL")

        sut.loadPosterImage()?.sink(receiveValue: { XCTAssertNotNil($0) }).store(in: &self.subscriptions)
    }

    func makeSUT(expectation: ResponseExpectation, urlString: String = "https://www.somepath.com") -> MovieListCellViewModel {
        return MovieListCellViewModel(movie: .init(title: "A title",
                                                   overview: "An overview",
                                                   posterPath: urlString),
                                      imageProvider: DummyImageLoader(expectation: expectation))
    }
}

final class DummyImageLoader: ImageProvider {

    let expectation: ResponseExpectation

    init(expectation: ResponseExpectation) {
        self.expectation = expectation
    }

    func loadPosterImage(urlString: String) -> AnyPublisher<UIImage?, Never>? {
        if expectation == .success {
            return Just(UIImage()).eraseToAnyPublisher()
        } else {
            return Just(nil).eraseToAnyPublisher()
        }
    }
}
