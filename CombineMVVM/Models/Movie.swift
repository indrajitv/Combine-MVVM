//
//  Movie.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation

struct Page: Decodable {
    let pageNumber: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]

    enum CodingKeys: String, CodingKey {
        case pageNumber = "page"
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}

struct Movie: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
}
