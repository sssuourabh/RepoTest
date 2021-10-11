//
//  RepoClient.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 29/09/21.
//

import Foundation
import Combine
import UIKit

protocol RepoClient {
    func getRepos(pageNumber: Int) -> AnyPublisher<Repos, Error>
    func loadImage(for repo: Repo) -> AnyPublisher<UIImage?, Never>
}

final class RepoClientImpl: RepoClient {

    private let networkService: NetworkServiceType
    private let imageLoaderService: ImageLoaderServiceType

    init(networkService: NetworkServiceType, imageLoaderService: ImageLoaderServiceType) {
        self.networkService = networkService
        self.imageLoaderService = imageLoaderService
    }

    func getRepos(pageNumber: Int) -> AnyPublisher<Repos, Error> {
        return networkService
            .load(Resource<Repos>.repos(query: pageNumber % 2 == 0 ? "apple" : "swift", pageNumber: pageNumber))
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func loadImage(for repo: Repo) -> AnyPublisher<UIImage?, Never> {
        print("repo.owner.avatarUrl = \(repo.owner.avatarUrl)")
        
        return Deferred { return Just(repo.id)}
            .flatMap({[unowned self] id -> AnyPublisher<UIImage?, Never> in
//                guard let name = repo.name else { return .just(nil)}
//                guard let urlString = repo.owner.avatarUrl else { return .just(nil)}
                guard let url = URL(string: repo.owner.avatarUrl) else { return .just(nil)}
                return self.imageLoaderService.loadImage(from: url)
            })
            .subscribe(on: Scheduler.backgroundScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
        
//        return imageLoaderService.loadImage(from: URL(string: repo.owner.avatarUrl)!)
//            .subscribe(on: Scheduler.backgroundScheduler)
//            .receive(on: Scheduler.mainScheduler)
//            .eraseToAnyPublisher()
    }

}
