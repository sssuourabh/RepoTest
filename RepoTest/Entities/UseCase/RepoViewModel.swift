//
//  RepoViewModel.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation
import Combine
import UIKit.UIImage

struct RepoViewModel {
    let id: Int
    let name: String
    let fullName: String
    let description: String
    let forks: Int
    let openIssues: Int
    let watchers: Int
    let avatarImage: AnyPublisher<UIImage?, Never>

    init(id: Int, name: String, fullName: String, description: String, forks: Int, openIssues: Int, watchers: Int, avatarImage: AnyPublisher<UIImage?, Never>) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.description = description
        self.forks = forks
        self.openIssues = openIssues
        self.watchers = watchers
        self.avatarImage = avatarImage
    }
}

extension RepoViewModel: Hashable {
    static func == (lhs: RepoViewModel, rhs: RepoViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


struct RepoViewModelBuilder {
    static func viewModel(from repo: Repo,
                          imageLoader: (Repo) -> AnyPublisher<UIImage?, Never>)
    -> RepoViewModel {
        return RepoViewModel(id: repo.id,
                             name: repo.name,
                             fullName: repo.fullName,
                             description: repo.description,
                             forks: repo.forks,
                             openIssues: repo.openIssues,
                             watchers: repo.watchers,
                             avatarImage: imageLoader(repo)
        )
    }
}
