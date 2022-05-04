//
//  SearchResponse.swift
//  GithubWithCombine
//
//  Created by Dorra Ben Abdelwahed on 25/4/2022.
//

import Foundation


struct SearchResponse: Decodable {
    let items: [Repo]
}
