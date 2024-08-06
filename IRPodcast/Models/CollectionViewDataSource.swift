//
//  CollectionViewDataSource.swift
//  IRPodcast
//
//  Created by Phil on 2025/8/3.
//

import UIKit

class CollectionViewDataSource<Model, Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource {

    typealias CellConfigurator = (Model, Cell) -> Void

    private var models: [Model]
    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator

    private init(models: [Model], reuseIdentifier: String, cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

    func update(with models: [Model]) {
        self.models = models
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = cell as? Cell else {
            return cell
        }
        let model = models[indexPath.item]
        cellConfigurator(model, cell)
        return cell
    }
}

extension CollectionViewDataSource where Model == Podcast, Cell == FavoritePodcastCell {

    static func makeAndRegister(
        for podcasts: [Podcast],
        on collectionView: UICollectionView,
        reuseIdentifier: String = FavoritePodcastCell.typeName
    ) -> CollectionViewDataSource {

        return CollectionViewDataSource(
            models: podcasts,
            reuseIdentifier: reuseIdentifier
        ) { podcast, cell in

            collectionView.register(Cell.self, forCellWithReuseIdentifier: reuseIdentifier)
            cell.populate(podcast: podcast)
            cell.layoutIfNeeded()
        }
    }
}
