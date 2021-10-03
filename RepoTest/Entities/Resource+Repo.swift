//
//  Resource+Repo.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation

extension Resource {
    static func repos(query: String, userId: String = "sssuourabh") -> Resource<Repos> {
        let url = APIConstants.baseUrl.appendingPathComponent("/search/repositories")
        let parameters: [String : CustomStringConvertible] = [
            "q": query
        ]
        return Resource<Repos>(url: url, parameters: parameters)
    }
}
