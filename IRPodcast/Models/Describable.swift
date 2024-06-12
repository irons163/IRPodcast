//
//  Describable.swift
//  IRPodcast
//
//  Created by irons on 2021/5/29.
//

import Foundation

protocol Describable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension Describable {
    
    var typeName: String {
        return String(describing: self)
    }

    static var typeName: String {
        return String(describing: self)
    }
}

extension Describable where Self: NSObjectProtocol {
    var typeName: String {
        return String(describing: type(of: self))
    }
}
