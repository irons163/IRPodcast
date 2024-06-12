//
//  PodcastsSearchViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit
//import Alamofire

// TODO: Replase strings with type-safety values

final class PodcastsSearchViewController: UITableViewController {

    // MARK: - Properties
//    fileprivate var podcasts = [Podcast]()
    var viewModel = PodcastsSearchViewModel()
    fileprivate var timer: Timer?
    fileprivate let searchController = UISearchController(searchResultsController: nil)
//    fileprivate var dataSource: TableViewDataSource<Podcast, PodcastCell>?
    var a: A?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: PodcastsSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesSearchBarWhenScrolling = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.hidesSearchBarWhenScrolling = true
        super.viewDidAppear(animated)
    }

}


// MARK: - UITableView
extension PodcastsSearchViewController {

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return podcasts.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
//        cell.podcast = podcasts[indexPath.row]
//        return cell
//    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Sizes.cellHeight
    }

    // MARK: Header Setup
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let emptyStateView = setupEmptyStateView()
        return emptyStateView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? (tableView.bounds.height / 2) : 0
//        return viewModel.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? (tableView.bounds.height / 2) : 0
        let height = Sizes.headerHeight(for: tableView)
        return viewModel.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? height : 0
    }

    // MARK: Footer Setup
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let podcastsSearchingView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self)?.first as? UIView
        let podcastsSearchingView = Bundle.main.loadNibNamed(Strings.podcastsSearchingView, owner: self)?.first as? UIView
        return podcastsSearchingView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
        return viewModel.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? Sizes.footerHeight : 0
    }

    // MARK: Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let podcast = viewModel.podcast(for: indexPath)
        let episodesViewModel = EpisodesViewModel(podcast: podcast)
        let episodesController = EpisodesViewController(viewModel: episodesViewModel)
        navigationController?.pushViewController(episodesController, animated: true)
    }
}


// MARK: - UISearchBarDelegate
extension PodcastsSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.deleteLoadedPodcasts()
        viewModel.searchPodcasts(with: searchText) {
            self.tableView.dataSource = self.viewModel.dataSource
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.deleteLoadedPodcasts()
        tableView.reloadData()
    }
    
    fileprivate func setupEmptyStateView() -> UIView {
        let label = UILabel()
        label.text = Strings.enterSearchTermMessage
        label.textAlignment = .center
        label.textColor = .purple
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

}


// MARK: - Setup
extension PodcastsSearchViewController {

    fileprivate func initialSetup() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.searchController = searchController
        title = Strings.title
    }

    private func setupSearchBar() {
//        self.definesPresentationContext                   = true
//        navigationItem.searchController                   = searchController
//        navigationItem.hidesSearchBarWhenScrolling        = false
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.delegate               = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation     = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.definesPresentationContext           = true
        searchController.searchBar.placeholder                = Strings.searchBarPlaceholder
        searchController.searchBar.delegate                   = self
    }

    private func setupTableView() {
//        tableView.dataSource = dataSource
        tableView.dataSource = viewModel.dataSource
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: PodcastCell.typeName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PodcastCell.typeName)
    }

}

private extension PodcastsSearchViewController {

    enum Strings {
        static let podcastsSearchingView = "PodcastsSearchingView"
        static let enterSearchTermMessage = "Please, enter a search term."
        static let searchBarPlaceholder   = "Search"
        static let title   = "Search"
    }

    enum Sizes {
        static let cellHeight: CGFloat = 132
        static let footerHeight: CGFloat = 200

        static func headerHeight(for tableView: UITableView) -> CGFloat {
            return tableView.bounds.height / 2
        }
    }
}
