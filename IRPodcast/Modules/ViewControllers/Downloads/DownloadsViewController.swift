//
//  DownloadsViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

final class DownloadsViewController: UITableViewController {

    // MARK: - Properties
    private let reuseIdentifier = "EpisodeCell"
    private var viewModel: DownloadsViewMoel

    init(viewModel: DownloadsViewMoel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.onDataUpdated = { [weak self] in
            guard let self else {
                return
            }
            tableView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .downloadProgress, object: nil)
        NotificationCenter.default.removeObserver(self, name: .downloadComplete, object: nil)
    }
}

// MARK: - TableView
extension DownloadsViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\n\t\tLaunch episode player")
        let episodes = viewModel.episodes
        let episode = episodes[indexPath.row]

        if episode.fileUrl != nil {
            UIApplication.mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Cannot find local file, play using stream URL instead", preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                UIApplication.mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(alertController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
        viewModel.deleteEpisode(at: indexPath.row)
    }
}

// MARK: - Setup
extension DownloadsViewController {

    private func initialSetup() {
        setupTableView()
        setupObservers()
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = viewModel.dataSource
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }

    @objc private func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }

        print("\n\t\t", progress, title)

        guard let index = viewModel.episodes.firstIndex(where: { $0.title == title }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false

        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }

    @objc private func handleDownloadComplete(notification: Notification) {
        guard let  episodeDownloadComplete = notification.object as? NetworkService.EpisodeDownloadComplete else { return }
        var episodes = viewModel.episodes
        guard let index = episodes.firstIndex(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
        episodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
}
