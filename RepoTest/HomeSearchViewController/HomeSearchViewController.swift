//
//  HomeSearchViewController.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 20/09/21.
//

import Foundation
import UIKit
import Combine
import Carbon
import Cartography

class HomeSearchViewController: UIViewController {
    
    struct State {
        public var reposArray = [RepoViewModel]()
        var pageNumber: Int = 1
        var canLoadNextPage = true
        var isLoading = false
    }
    
    private var state: State
    public let dataclient: RepoClient
    // MARK: // Properties
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    private let cellReuseIdentifier = "cell"

    // FIXME: - Whether it's advised to hold viewmodel object or not
    private lazy var dataSource = makeDataSource()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .tertiarySystemGroupedBackground
        return tableView
    }()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: Initialization
    init(dataclient: RepoClient) {
        self.dataclient = dataclient
        self.state = State()
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Github Repos", comment: "Title string")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        Cartography.constrain(tableView, activityIndicator) {
            $0.edges == $0.superview!.edges
            $1.width == 100
            $1.height == 100
            $1.centerX == $1.superview!.centerX
            $1.centerY == $1.superview!.centerY
        }
    }
    
    override func viewDidLoad() {
        tableView.register(RepoCell.self,
                           forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        getRepoData()
    }
    
    private func getRepoData() {
        guard state.canLoadNextPage else { return }
        dataclient.getRepos(pageNumber: state.pageNumber)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure: break
                case .finished:
                    self.update(with: self.state.reposArray)
                }
            }, receiveValue: { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let repositories):
                    let viewModels = self.viewModels(from: repositories.items)
                    self.state.reposArray.append(contentsOf: viewModels)
                    self.state.pageNumber += 1
                    self.state.isLoading = false
                    self.state.canLoadNextPage = viewModels.count == 10
                }
            })
            .store(in: &cancellables)
    }
}

fileprivate extension HomeSearchViewController {
    enum Section: CaseIterable {
        case main
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Section, RepoViewModel> {
        let reuseIdentifier = cellReuseIdentifier

        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, repoViewModel in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as! RepoCell
                
                let repoViewModel = self.state.reposArray[indexPath.row]
                cell.updateCell(from: repoViewModel)
                return cell
            }
        )
    }
    
    func update(with repoViewModel: [RepoViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, RepoViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(repoViewModel, toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    private func viewModels(from repos: [Repo]) -> [RepoViewModel] {
        return repos.map { repo in
            return RepoViewModelBuilder.viewModel(from: repo, imageLoader: { [unowned self] repo in
                self.dataclient.loadImage(for: repo)
            })
        }
    }
}

extension HomeSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Infinite scrolling.
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - tableView.frame.size.height && !state.isLoading) {
            state.isLoading = true
            getRepoData()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("shjkdhkh dhd")
    }
}
