//
//  FavoritesViewModel.swift
//  IRPodcast
//
//  Created by Phil on 2025/8/3.
//

final class FavoritesViewModel {

    // MARK: - Properties
    var podcasts = [Podcast]()
    var dataSource: CollectionViewDataSource<Podcast>?

    func deletePodcast(at index: Int) {
        podcasts.remove(at: index)
        dataSource = CollectionViewDataSource(models: podcasts, cellConfigurator: { podcast, cell in
            if let cell = cell as? FavoritePodcastCell {
                cell.populate(podcast: podcast)
            }
            cell.layoutIfNeeded()
        })
    }
}
