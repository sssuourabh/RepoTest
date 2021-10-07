//
//  HomeSearchViewControllerTests.swift
//  RepoTestTests
//
//  Created by Caio Zullo on 07/10/2021.
//

import XCTest
import Combine
@testable import RepoTest

struct NullRepoClient: RepoClient {
	func getRepos(pageNumber: Int) -> AnyPublisher<Repos, Error> {
		Empty().eraseToAnyPublisher()
	}
	
	func loadImage(for repo: Repo) -> AnyPublisher<UIImage?, Never> {
		fatalError()
	}
}

struct RepoClientStub: RepoClient {
	let repos: (Int) -> Result<Repos, Error>

	func getRepos(pageNumber: Int) -> AnyPublisher<Repos, Error> {
		Future { completion in
			do {
				let repos = try self.repos(pageNumber).get()
				return completion(.success(repos))
			} catch {
				return completion(.failure(error))
			}
		}.eraseToAnyPublisher()
	}
	
	func loadImage(for repo: Repo) -> AnyPublisher<UIImage?, Never> {
		Empty().eraseToAnyPublisher()
	}
}

class HomeSearchViewControllerTests: XCTestCase {

    func test_initialState_isEmpty() {
		let client = NullRepoClient()
		let sut = HomeSearchViewController(dataclient: client)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.numberOfRepos(), 0)
    }
	
	func test_stateForFirstPage_whenClientFails_isEmpty() {
		let client = RepoClientStub(repos: { page in
			XCTAssertEqual(page, 1)
			return .failure(AnyError())
		})
		let sut = HomeSearchViewController(dataclient: client)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.numberOfRepos(), 0)
	}
	
	func test_stateForFirstPage_whenClientReturnsSomeRepos_isNotEmpty() {
		let client = RepoClientStub(repos: { page in
			XCTAssertEqual(page, 1)
			return .success(Repos(items: [
				makeRepo(id: 1, name: "repo 1"),
				makeRepo(id: 2, name: "repo 2")
			]))
		})
		let sut = HomeSearchViewController(dataclient: client)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.numberOfRepos(), 2)
//		XCTAssertEqual(sut.repoName(at: 0), "repo 1")
//		XCTAssertEqual(sut.repoName(at: 1), "repo 2")
	}
	
	func test_didScroll_doesNotRequestSecondPage_whenFirstPageHasLessThan10Items() {
		let client = RepoClientStub(repos: { page in
			XCTAssertEqual(page, 1)
			return .success(Repos(items: (1...9).map { makeRepo(id: $0) }))
		})
		let sut = HomeSearchViewController(dataclient: client)
		
		sut.loadViewIfNeeded()
		
		sut.tableView.contentOffset = CGPoint(x: 0, y: 1000)
		sut.scrollViewDidScroll(sut.tableView)
		
		XCTAssertEqual(sut.numberOfRepos(), 9)
	}
	
	func test_didScroll_requestsSecondPage_whenFirstPageHasAtLeast10Items() {
		let client = RepoClientStub(repos: { page in
			if page == 1 {
				return .success(Repos(items: (1...10).map { makeRepo(id: $0) }))
			} else if page == 2 {
				return .success(Repos(items: (11...13).map { makeRepo(id: $0) }))
			} else {
				XCTFail("shouldn't have request page \(page)")
				return .failure(AnyError())
			}
		})
		let sut = HomeSearchViewController(dataclient: client)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.numberOfRepos(), 10)
		
		sut.tableView.contentOffset = CGPoint(x: 0, y: 1000)
		sut.scrollViewDidScroll(sut.tableView)
		
		XCTAssertEqual(sut.numberOfRepos(), 13)
	}


}

private extension HomeSearchViewController {
	func numberOfRepos() -> Int {
		tableView.numberOfRows(inSection: 0)
	}
	
//	func repoName(at row: Int) -> String? {
//		tableView...
//	}
}

private func makeRepo(id: Int, name: String = "any name") -> Repo {
	Repo(id: id, name: name, fullName: "any fullname", description: "any description", forks: 0, openIssues: 0, watchers: 0, owner: Owner(avatarUrl: "http://any-url.com"))
}

private struct AnyError: Error {}
