//
//  HomeSearchViewController2.swift
//  RepoTest
//
//  Created by Sourabh Singh on 09/10/21.
//
// Adding infinite scrollwith prefetch api's

import Foundation
import UIKit
import Combine
import Carbon
import Cartography

class HomeSearchViewController2: UIViewController {
    
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
    private let refreshControl = UIRefreshControl()

    // FIXME: - Whether it's advised to hold viewmodel object or not
    private lazy var dataSource = makeDataSource()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.tableFooterView = UIView(frame: .zero)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateStateAndFetchData))

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        Cartography.constrain(tableView) {
            $0.edges == $0.superview!.edges
        }
        tableView.addSubview(refreshControl)
    }
    
    override func viewDidLoad() {
        tableView.register(RepoCell.self,
                           forCellReuseIdentifier: cellReuseIdentifier)
        tableView.tableFooterView = activityIndicator
        
        tableView.dataSource = dataSource
//        tableView.prefetchDataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(updateStateAndFetchData), for: .valueChanged)
        
        getRepoData()
    }
    
    private func getRepoData() {
        activityIndicator.startAnimating()
        guard state.canLoadNextPage else { return }
        dataclient.getRepos(pageNumber: state.pageNumber)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure: break
                case .finished:
                    self.update(with: self.state.reposArray)
                }
            }, receiveValue: { repositories in
                if self.refreshControl.isRefreshing {
                    self.state.reposArray.removeAll()
                    self.refreshControl.endRefreshing()
                }
                let viewModels = self.viewModels(from: repositories.items)
                self.state.reposArray.append(contentsOf: viewModels)
                self.state.pageNumber += 1
                self.state.isLoading = false
                self.state.canLoadNextPage = viewModels.count == 10
            })
            .store(in: &cancellables)
    }
    
    @objc private func updateStateAndFetchData() {
        //scroll to top
        scrollToFirstRow()
        // update state to initial value
        refreshControl.beginRefreshing()
        state.pageNumber = 1
        state.canLoadNextPage = true
        state.isLoading = false
        // fetch data
        getRepoData()
    }
    
    private func scrollToFirstRow() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
      }
}

fileprivate extension HomeSearchViewController2 {
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, RepoViewModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(repoViewModel, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    private func viewModels(from repos: [Repo]) -> [RepoViewModel] {
        return repos.map { repo in
            return RepoViewModelBuilder.viewModel(from: repo, imageLoader: { [unowned self] repo in
                self.dataclient.loadImage(for: repo)
            })
        }
    }
}

extension HomeSearchViewController2: UITableViewDelegate {

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
    
    //Prefetch
    
}


//extension HomeSearchViewController2: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        print("Prefetch rows at: \(indexPaths)")
//        let needsFetch = indexPaths.contains { $0.row >= self.state.reposArray.count }
//        if needsFetch {
//            getRepoData()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//
//        }
//
//}
