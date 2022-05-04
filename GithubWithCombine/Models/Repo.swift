//
//  Repo.swift
//  GithubWithCombine
//
//  Created by Dorra Ben Abdelwahed on 25/4/2022.
//

import Foundation


struct Repo: Decodable {
    
    let id: Int
    let name: String
    let description: String?
    let stargazers_count: Int
    let html_url: URL

    
   
}
