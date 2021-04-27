//
//  PodcastsSearchViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit
import Alamofire

// TODO: Replase strings with type-safety values

final class PodcastsSearchViewController: UITableViewController {

    // MARK: - Properties
    fileprivate var podcasts = [Podcast]()
    fileprivate var timer: Timer?
    fileprivate let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

}


// MARK: - UITableView
extension PodcastsSearchViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    // MARK: Header Setup
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please, enter a search term."
        label.textAlignment = .center
        label.textColor = .purple
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? (tableView.bounds.height / 2) : 0
    }

    // MARK: Footer Setup
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let podcastsSearchingView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self)?.first as? UIView
        return podcastsSearchingView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
    }

    // MARK: Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesViewController()
        let podcast = podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
}


// MARK: - UISearchBarDelegate
extension PodcastsSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        podcasts = []
        tableView.reloadData()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
            NetworkService.shared.fetchPodcasts(searchText: searchText, completionHandler: { podcasts in
                self.podcasts = podcasts
                self.tableView.reloadData()
            })
        })
    }

}


// MARK: - Setup
extension PodcastsSearchViewController {

    fileprivate func initialSetup() {
        setupSearchBar()
        setupTableView()
    }

    private func setupSearchBar() {
        self.definesPresentationContext                   = true
        navigationItem.searchController                   = searchController
        navigationItem.hidesSearchBarWhenScrolling        = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate               = self
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodcastCell")
    }
}
