//
//  Movie.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation

struct Page: Decodable {
    let results: [Movie]
}

struct Movie: Decodable, Hashable {
    let title: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case posterPath = "poster_path"
    }
}
