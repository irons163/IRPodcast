//
//  TableViewDataSource.swift
//  IRPodcast
//
//  Created by irons on 2021/9/28.
//

import UIKit

class TableViewDataSource<Model, Cell: UITableViewCell>: NSObject, UITableViewDataSource {
    
    typealias CellConfigurator = (Model, Cell) -> Void
    
    var models: [Model] = []
    
    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator
    
    private init(
        models: [Model],
        reuseIdentifier: String,
        cellConfigurator: @escaping CellConfigurator
    ) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? Cell {
            cellConfigurator(model, cell)
        }
        return cell
    }
}

extension TableViewDataSource where Model == Podcast {

    static func make(
        for podcasts: [Podcast],
        reuseIdentifier: String = PodcastCell.typeName
    ) -> TableViewDataSource {

        return TableViewDataSource(
            models: podcasts,
            reuseIdentifier: reuseIdentifier
        ) { podcast, cell in
            if let cell = cell as? PodcastCell {
                cell.podcast = podcast
            }
            cell.layoutIfNeeded()
        }
    }
}

extension TableViewDataSource where Model == Episode {

    static func make(
        for episodes: [Episode],
        reuseIdentifier: String = EpisodeCell.typeName
    ) -> TableViewDataSource {

        return TableViewDataSource(
            models: episodes,
            reuseIdentifier: reuseIdentifier
        ) { episode, cell in
            if let cell = cell as? EpisodeCell {
                cell.episode = episode
            }
            cell.layoutIfNeeded()
        }
    }
}
