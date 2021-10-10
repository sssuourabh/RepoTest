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
        return imageLoaderService.loadImage(from: URL(string: repo.owner.avatarUrl)!)
    }

}
