//
//  FavoritesViewModel.swift
//  IRPodcast
//
//  Created by Phil on 2025/8/3.
//

import Foundation

final class FavoritesViewModel {

    // MARK: - Properties
    private(set) var podcasts: [Podcast] = UserDefaults.standard.savedPodcasts
    lazy var dataSource: CollectionViewDataSource<Podcast> = {
        CollectionViewDataSource(models: podcasts, cellConfigurator: { podcast, cell in
            if let cell = cell as? FavoritePodcastCell {
                cell.populate(podcast: podcast)
            }
            cell.layoutIfNeeded()
        })
    }()

    func deletePodcast(at index: Int) {
        UserDefaults.standard.deletePodcast(at: index)
        dataSource.update(with: podcasts)
    }
}
