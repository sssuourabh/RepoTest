//
//  Repo.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation

import Foundation

struct Repo {
    let id: Int
    let name: String
    let fullName: String
    let description: String
    let forks: Int
    let openIssues: Int
    let watchers: Int
    let owner: Owner
}

struct Owner: Decodable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}

extension Repo: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case forks
        case openIssues = "open_issues"
        case watchers
        case owner
    }
}

extension Repo: Hashable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Repos {
    let items: [Repo]
}

extension Repos: Decodable {

    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
}
