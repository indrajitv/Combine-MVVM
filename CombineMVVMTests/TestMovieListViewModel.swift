//
//  TestMovieListViewModel.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 16/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

final class TestMovieListViewModel: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func test_constantStrings() {
        let sut = makeSUT(expectation: .success)
        XCTAssertEqual(sut.navigationTitle, "Movies")
        XCTAssertEqual(sut.searchBarPlaceholder, "Search")
        XCTAssertEqual(sut.tableSwipeDeleteActionText, "Delete")
    }

    func test_getMovieList_shouldReturnArrayOfViewModels_AndThreadShouldBeMain() {
        let sut = makeSUT(expectation: .success)
        var movies: [MovieListCellViewModel] = []

        sut.getMovieList()
            .sink { completion in

            } receiveValue: { _movies in
                movies = _movies
                XCTAssertTrue(Thread.isMainThread)
            }
            .store(in: &self.subscriptions)

        XCTAssertTrue(movies.count > 0)
        XCTAssertTrue(sut.movieListCellViewModels.count == movies.count)
        XCTAssertNil(sut.reservedMovieListCellViewModels)
    }

    func test_getMovieList_shouldReturnEmptyArrayOfViewModels_whiteStatusIsStillSuccess() {
        let sut = makeSUT(expectation: .successWithEmptyVieWModels)
        let movies: [MovieListCellViewModel] = loadMovies(from: sut)

        XCTAssertTrue(movies.isEmpty)
        XCTAssertTrue(sut.movieListCellViewModels.isEmpty)
        XCTAssertNil(sut.reservedMovieListCellViewModels)
    }

    func test_getMovieList_shouldReturnArrayOfViewModels_withoutAppendingOnSameArrayFromPreviousResult() {
        let sut = makeSUT(expectation: .success)
        var movies: [MovieListCellViewModel] = loadMovies(from: sut)

        let movieCount = movies.count
        XCTAssertTrue(movieCount > 0)
        XCTAssertTrue(sut.movieListCellViewModels.count == movieCount)

        movies = loadMovies(from: sut)

        XCTAssertTrue(sut.movieListCellViewModels.count == movieCount)

        XCTAssertNil(sut.reservedMovieListCellViewModels)
    }

    func test_getMovieList_shouldReturnFailureAndViewModelShouldBeEmpty() {
        let sut = makeSUT(expectation: .failure)

        sut.getMovieList()
            .sink { completion in
                var error: Error?
                if case .failure(let _error) = completion {
                    error = _error
                }
                XCTAssertNotNil(error)
            } receiveValue: { _ in
                assertionFailure("Did not expect to get movies.")
            }
            .store(in: &self.subscriptions)

        XCTAssertTrue(sut.movieListCellViewModels.isEmpty)

        XCTAssertNil(sut.reservedMovieListCellViewModels)
    }

    func test_filterCurrentMovies_reservedMoviesShouldAssignOnlyOnce_whileSearchingContinously() {
        let sut = makeSUT(expectation: .success)
        let loadedMovies = loadMovies(from: sut)

        sut.filterCurrentMovies(with: "1 Title")

        let reserved = sut.reservedMovieListCellViewModels

        XCTAssertNotNil(sut.reservedMovieListCellViewModels)
        XCTAssertEqual(loadedMovies.count, sut.reservedMovieListCellViewModels?.count)

        sut.filterCurrentMovies(with: "1 Title")

        XCTAssertEqual(reserved, sut.reservedMovieListCellViewModels)
    }

    func test_filterCurrentMovies_reservedShouldBeNilAndMainArrayShouldReset_whileFinishingTypingOrTypingEmptyString() {
        let sut = makeSUT(expectation: .success)
        let loadedMovies = loadMovies(from: sut)

        sut.filterCurrentMovies(with: "1 Title")

        XCTAssertNotNil(sut.reservedMovieListCellViewModels)
        XCTAssertEqual(loadedMovies.count, sut.reservedMovieListCellViewModels?.count)
        XCTAssertEqual(sut.movieListCellViewModels.count, 1)

        sut.filterCurrentMovies(with: "")

        XCTAssertNil(sut.reservedMovieListCellViewModels)
        XCTAssertEqual(sut.movieListCellViewModels.count, loadedMovies.count)
    }

    func test_filterCurrentMovies_shouldGetDesiredOutput_irrespectiveOfCase_whileTypingDiffrentSearchQueries() {
        let sut = makeSUT(expectation: .success)
        _ = loadMovies(from: sut)

        let result1 = sut.filterCurrentMovies(with: "1")
        XCTAssertEqual(result1.count, 2)
        XCTAssertEqual(result1[0].title, "1 Title")
        XCTAssertEqual(result1[1].title, "10 Title")

        let result2 = sut.filterCurrentMovies(with: "1 Title")
        XCTAssertEqual(result2.count, 1)
        XCTAssertEqual(result2[0].title, "1 Title")

        let result3 = sut.filterCurrentMovies(with: "1 tItLe")
        XCTAssertEqual(result3.count, 1)
        XCTAssertEqual(result3[0].title, "1 Title")

        let result4 = sut.filterCurrentMovies(with: "4 tItLe")
        XCTAssertEqual(result4.count, 1)
        XCTAssertEqual(result4[0].title, "4 Title")

        let result5 = sut.filterCurrentMovies(with: "")
        XCTAssertEqual(result5.count, 10)
        XCTAssertEqual(result5[0].title, "1 Title")
        XCTAssertEqual(result5[9].title, "10 Title")

        let result6 = sut.filterCurrentMovies(with: "title")
        XCTAssertEqual(result6.count, 10)
        XCTAssertEqual(result6[0].title, "1 Title")
        XCTAssertEqual(result6[9].title, "10 Title")
    }

    func test_filterCurrentMovies_whatIfArrayWasEmpty() {
        let sut = makeSUT(expectation: .successWithEmptyVieWModels)
        _ = loadMovies(from: sut)

        let result1 = sut.filterCurrentMovies(with: "1")
        XCTAssertEqual(result1.count, 0)

        let result2 = sut.filterCurrentMovies(with: "")
        XCTAssertEqual(result2.count, 0)
    }

    func test_deleteMovieAt_shouldDeleteFromMainAndReservedArray_whileDeletingOnSearchResult() {
        let sut = makeSUT(expectation: .success)
        _ = loadMovies(from: sut)

        let result1 = sut.filterCurrentMovies(with: "1")
        XCTAssertEqual(result1.count, 2)

        let deleted = try! sut.deleteMovieAt(at: 0)
        XCTAssertEqual(deleted.title, "1 Title")

        XCTAssertEqual(sut.reservedMovieListCellViewModels!.count, 9)
        XCTAssertEqual(sut.movieListCellViewModels.count, 1)
    }

    func test_deleteMovieAt_shouldThrowOutOfIndexError() {
        let sut = makeSUT(expectation: .success)
        _ = loadMovies(from: sut)

        let result1 = sut.filterCurrentMovies(with: "1")
        XCTAssertEqual(result1.count, 2)
        XCTAssertThrowsError(try sut.deleteMovieAt(at: 2))

        let result2 = sut.filterCurrentMovies(with: "title")
        XCTAssertEqual(result2.count, 9) // Because we deleted 1.
        XCTAssertThrowsError(try sut.deleteMovieAt(at: 9))
    }

    func test_deleteMovieAt_whatIfWeDeleteItemFromEmptyArray() {
        let sut = makeSUT(expectation: .successWithEmptyVieWModels)
        _ = loadMovies(from: sut)

        XCTAssertThrowsError(try sut.deleteMovieAt(at: 0))
        XCTAssertThrowsError(try sut.deleteMovieAt(at: 9))
    }

    func loadMovies(from sut: MovieListViewModel) -> [MovieListCellViewModel] {
        var movies: [MovieListCellViewModel] = []
        sut.getMovieList()
            .sink { completion in

            } receiveValue: { _movies in
                movies = _movies
            }
            .store(in: &self.subscriptions)
        return movies
    }

    func makeSUT(expectation: ResponseExpectation) -> MovieListViewModel {
        let viewModel = MovieListViewModel(movieProvider: MockedMovieProvider(expectation: expectation))
        return viewModel
    }
}
