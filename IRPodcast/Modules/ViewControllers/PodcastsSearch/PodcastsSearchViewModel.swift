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
    
    fileprivate var timer: Timer?

    func searchPodcasts(with query: String, completion: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
            NetworkService.shared.fetchPodcasts(searchText: query, completionHandler: {
//                [weak self]
                podcasts in
                self.podcastsDidLoad(podcasts)
                DispatchQueue.main.async {
                    completion()
                }
            })
        })
    }
    
    fileprivate func podcastsDidLoad(_ podcasts: [Podcast]) {
//        self.podcasts = podcasts
//        dataSource = .make(for: podcasts)
//        tableView.dataSource = dataSource
        self.podcasts = podcasts
        dataSource = .make(for: podcasts)
    }

    func deleteLoadedPodcasts() {
//        podcasts.removeAll()
//        dataSource = .make(for: podcasts)
//        tableView.dataSource = dataSource
        podcasts.removeAll()
        dataSource = .make(for: podcasts)
    }

    func podcast(for indexPath: IndexPath) -> Podcast {
//        return podcasts[indexPath.row]
        return podcasts[indexPath.row]
    }
}

class A {
    
}
