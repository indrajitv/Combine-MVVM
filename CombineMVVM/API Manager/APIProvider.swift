//
//  APIProvider.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation
import Combine

protocol APIProvider {
    var apiKey: String { get }
    var hostPath: String { get }

    func execute<T: Decodable>(apiRequest: APIRequest, value: T.Type, queue: DispatchQueue) -> Future<T, CustomError>
    func execute<T: Decodable>(apiRequest: APIRequest, value: T.Type, queue: DispatchQueue) -> AnyPublisher<T, Error>
}

enum RequestMethod: String {
    case get, post
}

struct APIRequest {
    var path: String
    var type: RequestMethod
    var timeInterval: TimeInterval = 10
    var attempts: Int = 2
}
