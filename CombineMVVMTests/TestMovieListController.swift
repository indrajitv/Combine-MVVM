//
//  TestMovieListController.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 17/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

final class TestMovieListController: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func test_viewDidLoad_shouldLoadMoviesOnTable_whenAPIGivesSuccess() {
        let sut = self.makeSUT(expectation: .success)

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)
        XCTAssertEqual(sut.tableView.numberOfSections, 1)
    }

    func test_viewDidLoad_shouldNotLoadMoviesOnTable_whenAPIGivesSuccessButEmptyArray() {
        let sut = self.makeSUT(expectation: .successWithEmptyVieWModels)

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }

    func test_viewDidLoad_shouldNotLoadMoviesOnTable_whenAPIGivesFailure() {
        let sut = self.makeSUT(expectation: .failure)

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }

    func test_loadMovies_multipleLoadingShouldNotImpactRowsAndSection() {
        let sut = self.makeSUT(expectation: .success)
        sut.viewDidLoad()
        sut.viewDidLoad()
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)
        XCTAssertEqual(sut.tableView.numberOfSections, 1)
    }

    func test_tableShouldHaveOneSwipeActionItemWithValidTitle() {
        let sut = self.makeSUT(expectation: .success)

        let configurationClosure = sut.tableView(sut.tableView, trailingSwipeActionsConfigurationForRowAt: .init(row: 1, section: 0))
        XCTAssertEqual(configurationClosure!.actions.count, 1)
        XCTAssertEqual(configurationClosure!.actions[0].title!, "Delete")
    }

    func test_shouldDeleteOnSwipeOfTableCell() {
        let sut = self.makeSUT(expectation: .success)

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)
        XCTAssertEqual(sut.tableView.numberOfSections, 1)

        let configurationClosure = sut.tableView(sut.tableView, trailingSwipeActionsConfigurationForRowAt: .init(row: 1, section: 0))

        configurationClosure?.actions[0].handler(UIContextualAction(), UIView(), { bool in
            XCTAssertTrue(bool)
        })

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 9)
        XCTAssertEqual(sut.tableView.numberOfSections, 1)

        let configurationClosure2 = sut.tableView(sut.tableView, trailingSwipeActionsConfigurationForRowAt: .init(row: 3, section: 0))

        configurationClosure2?.actions[0].handler(UIContextualAction(), UIView(), { bool in
            XCTAssertTrue(bool)
        })

        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 8)
        XCTAssertEqual(sut.tableView.numberOfSections, 1)
    }

    func test_searchBar_shouldSearchAndReloadTheTableDatasourceItems() {
        let viewModel = MovieListViewModel(movieProvider: MockedMovieProvider(expectation: .success))
        let sut = MovieListController(viewMode: viewModel)
        _ = sut.view

        viewModel.filterCurrentMovies(with: "1 title")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)

        viewModel.filterCurrentMovies(with: "")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)

        viewModel.filterCurrentMovies(with: "title")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)

        viewModel.filterCurrentMovies(with: "Something random")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }

    func makeSUT(expectation: ResponseExpectation) -> MovieListController {
        let viewModel = MovieListViewModel(movieProvider: MockedMovieProvider(expectation: expectation))
        let vc = MovieListController(viewMode: viewModel)
        _ = vc.view
        return vc
    }
}
