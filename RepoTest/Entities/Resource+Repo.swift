//
//  Resource+Repo.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation

extension Resource {
    static func repos(query: String, pageNumber: Int) -> Resource<Repos> {
        let url = APIConstants.baseUrl.appendingPathComponent("/search/repositories")
        let parameters: [String : CustomStringConvertible] = [
            "q": query,
            "page": pageNumber,
            "per_page": 10
        ]
        return Resource<Repos>(url: url, parameters: parameters)
    }
}
