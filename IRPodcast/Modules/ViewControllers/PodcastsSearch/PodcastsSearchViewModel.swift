//
//  PodcastsSearchViewModel.swift
//  IRPodcast
//
//  Created by irons on 2021/9/28.
//

import UIKit

class PodcastsSearchViewModel {

    // MARK: - Properties
    var podcasts = [Podcast]()
    var dataSource: TableViewDataSource<Podcast, PodcastCell>?

    private var timer: Timer?

    func searchPodcasts(with query: String, completion: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
            NetworkService.shared.fetchPodcasts(searchText: query) { [weak self] podcasts in
                guard let self else {
                    return
                }
                self.podcastsDidLoad(podcasts)
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func deleteLoadedPodcasts() {
        podcasts.removeAll()
        dataSource = .make(for: podcasts)
    }

    func podcast(for indexPath: IndexPath) -> Podcast {
        return podcasts[indexPath.row]
    }
}

extension PodcastsSearchViewModel {

    private func podcastsDidLoad(_ podcasts: [Podcast]) {
        self.podcasts = podcasts
        dataSource = .make(for: podcasts)
    }
}
