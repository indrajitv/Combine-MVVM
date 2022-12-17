//
//  TestMovieListCell.swift
//  CombineMVVMTests
//
//  Created by Indrajit Chavda on 17/12/22.
//

import XCTest
import Combine

@testable import CombineMVVM

final class TestMovieListCell: XCTestCase {

    func test_cellID() {
        XCTAssertEqual(MovieListCell.cellID, "MovieListCell")
    }

    func test_preparedForReuse_allPropertiesShouldBeAtDefaultConfig() {
        let cell = MovieListCell()
        cell.prepareForReuse()

        XCTAssertNil(cell.titleLabel.text)
        XCTAssertNil(cell.descriptionLabel.text)
        XCTAssertNil(cell.posterImageView.image)
    }

    func test_subscribe_shouldChangeData_whilePublisherEmitsNewData() {

        let cell = MovieListCell()
        let viewModel = MovieListCellViewModel(movie: .init(title: "", overview: "", posterPath: ""),
                                               imageProvider: DummyImageLoader(expectation: .success))
        cell.configureCell(from: viewModel)

        XCTAssertEqual(cell.titleLabel.text, "")
        XCTAssertEqual(cell.descriptionLabel.text, "")
        XCTAssertEqual(cell.posterImageView.image, UIImage())

        viewModel.title = "A"
        viewModel.description = "B"

        XCTAssertEqual(cell.titleLabel.text, "A")
        XCTAssertEqual(cell.descriptionLabel.text, "B")
    }

    func test_subscribe_shouldChangeImage_whilePublisherEmitsNewImage() {

        let cell = MovieListCell()
        let viewModel = MovieListCellViewModel(movie: .init(title: "", overview: "", posterPath: ""),
                                               imageProvider: DummyImageLoader(expectation: .success))
        cell.configureCell(from: viewModel)

        XCTAssertEqual(cell.posterImageView.image, UIImage())

        let cell2 = MovieListCell()
        let viewModel2 = MovieListCellViewModel(movie: .init(title: "", overview: "", posterPath: ""),
                                               imageProvider: DummyImageLoader(expectation: .failure))
        cell2.configureCell(from: viewModel2)

        XCTAssertEqual(cell2.posterImageView.image, nil)
    }
}
