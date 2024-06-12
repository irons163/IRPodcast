//
//  EpisodesViewModel.swift
//  IRPodcast
//
//  Created by irons on 2021/12/23.
//

import Foundation

final class EpisodesViewModel {

    // MARK: - Properties
    let podcast: Podcast
    var episodes = [Episode]()
    var dataSource: TableViewDataSource<Episode, EpisodeCell>?

    init(podcast: Podcast) {
        self.podcast = podcast
    }

    func fetchEpisodes(_ completion: @escaping () -> Void) {
        print("\n\t\tLooking for episodes at feed url:", podcast.feedUrl ?? "")

        guard let feedURL = podcast.feedUrl else { return }
        NetworkService.shared.fetchEpisodes(feedUrl: feedURL) { [weak self] episodes in
            self?.episodesDidLoad(episodes)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func episodesDidLoad(_ episodes: [Episode]) {
        self.episodes = episodes
        dataSource = .make(for: episodes)
    }

}
