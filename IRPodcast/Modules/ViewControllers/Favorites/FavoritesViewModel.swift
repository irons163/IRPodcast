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

    var onDataUpdated: (() -> Void)?

    func deletePodcast(at index: Int) {
        UserDefaults.standard.deletePodcast(at: index)
        onDataUpdated?()
    }
}
