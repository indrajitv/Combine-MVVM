//
//  CustomError.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation

enum CustomError: Error {

    case network
    case cancelled
    case unknown
    case custom(description: String)
}
