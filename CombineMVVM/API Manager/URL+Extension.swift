//
//  URL+Extension.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import Foundation

extension URL {
    func url(with queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }

    init(_ host: String, _ apiKey: String, _ request: APIRequest) {
        let queryItems = [ ("api_key", apiKey) ]
            .map { name, value in URLQueryItem(name: name, value: "\(value)") }

        let url = URL(string: host)!
            .appendingPathComponent(request.path)
            .url(with: queryItems)

        self.init(string: url.absoluteString)!
    }
}
