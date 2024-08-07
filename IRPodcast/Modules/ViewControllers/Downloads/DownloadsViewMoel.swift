//
//  DownloadsViewMoel.swift
//  IRPodcast
//
//  Created by Phil on 2025/8/3.
//

import Foundation

final class DownloadsViewMoel {

    // MARK: - Properties
    private(set) var episodes = UserDefaults.standard.downloadedEpisodes
    lazy var dataSource: TableViewDataSource<Episode, EpisodeCell> = {
        .make(for: episodes)
    }()
    var onDataUpdated: (() -> Void)?

    func deleteEpisode(at index: Int) {
        UserDefaults.standard.deleteEpisode(at: index)
        onDataUpdated?()
    }
}
