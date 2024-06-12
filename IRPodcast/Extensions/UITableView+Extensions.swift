//
//  UITableView+Extensions.swift
//  IRPodcast
//
//  Created by irons on 2021/9/28.
//

import UIKit

extension UITableView {

    func dequeueCell<Cell: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
    }

}

