//
//  GithubService.swift
//  GithubWithCombine
//
//  Created by Dorra Ben Abdelwahed on 25/4/2022.
//

import Foundation
import Combine

class GithubService {
    
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
}

extension GithubService {
    
    func search(matching query: String) -> AnyPublisher<[Repo], Error> {
        guard
            let url = URL(string: "https://api.github.com/search/repositories?q=\(query)")
            else { preconditionFailure("Can't create url for query: \(query)") }
        
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: decoder)
            .map { $0.items }
            .eraseToAnyPublisher()
    }
}
