//
//  CollectionViewDataSource.swift
//  IRPodcast
//
//  Created by Phil on 2025/8/3.
//

import UIKit

class CollectionViewDataSource<Model>: NSObject, UICollectionViewDataSource {

    typealias CellConfigurator = (Model, UICollectionViewCell) -> Void

    private var models: [Model]
    private let reuseIdentifier: String = "FavoritePodcastCell"
    private let cellConfigurator: CellConfigurator

    init(models: [Model], cellConfigurator: @escaping CellConfigurator) {
        self.models = models
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
        guard let cell = cell as? FavoritePodcastCell else {
            return cell
        }
        let model = models[indexPath.item]
        cellConfigurator(model, cell)
        return cell
    }
}
