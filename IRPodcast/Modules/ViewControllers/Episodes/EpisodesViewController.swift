//
//  EpisodesViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

final class EpisodesViewController: UITableViewController {

    // MARK: - Properties
//    var podcast: Podcast? {
//        didSet {
//            navigationItem.title = podcast?.trackName
//            fetchEpisodes()
//        }
//    }
    fileprivate let viewModel: EpisodesViewModel

//    var episodes = [Episode]()
//    fileprivate let reuseIdentifier = "EpisodeCell"

    // MARK: - View Controller's life cycle
    init(viewModel: EpisodesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()

        viewModel.fetchEpisodes { [weak self] in
            guard let self = self else { return }
            self.navigationItem.title = self.viewModel.podcast.trackName
            self.tableView.reloadData()
        }
    }

}

// MARK: - UITableView
extension EpisodesViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            print("\n\t\tDownloading episode into UserDefaults")
            let episode = self.viewModel.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode)
            NetworkService.shared.downloadEpisode(episode)
        }
        return [downloadAction]
    }

    // MARK: Footer Setup
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.episodes.isEmpty ? 200 : 0
    }

    // MARK: Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = viewModel.episodes[indexPath.row]
        let mainTabBarController = UIApplication.mainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: viewModel.episodes)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Setup
extension EpisodesViewController {

    fileprivate func initialSetup() {
        setupTableView()
        setupNavigationBarButtons()
    }

    private func setupTableView() {
        let nib = UINib(nibName: EpisodeCell.typeName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: EpisodeCell.typeName)
        tableView.tableFooterView = UIView()
    }

    private func setupNavigationBarButtons() {
        let savedPodcasts = UserDefaults.standard.savedPodcasts
        let hasFavorited = savedPodcasts
            .firstIndex(where: { $0.trackName == self.viewModel.podcast.trackName &&
                $0.artistName == self.viewModel.podcast.artistName }) != nil

        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(saveFavorite))
        }
    }

    @objc private func saveFavorite() {
        print("\n\t\tSaving info into UserDefaults")

        let podcast = self.viewModel.podcast

        var listOfPodcasts = UserDefaults.standard.savedPodcasts
        listOfPodcasts.append(podcast)
        let data = try! NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)

        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)

        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    }

    private func showBadgeHighlight() {
        UIApplication.mainTabBarController?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }

}
