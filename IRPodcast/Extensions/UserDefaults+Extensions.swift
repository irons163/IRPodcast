//
//  UserDefaults+Extensions.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import Foundation

extension UserDefaults {

    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodesKey = "downloadEpisodesKey"

    var savedPodcasts: [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        let allowedClasses = [NSArray.self, IRPodcast.Podcast.self]
        guard let savedPodcasts = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: allowedClasses, from: savedPodcastsData) as? [Podcast] else { return [] }
        return savedPodcasts
    }

    var downloadedEpisodes: [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }

        do {
            return try JSONDecoder().decode([Episode].self, from: episodesData)
        } catch let decodeError {
            print("\n\t\tFailed to decode:", decodeError)
        }

        return []
    }

    func deletePodcast(_ podcast: Podcast) {
        let podcasts = savedPodcasts
        let filteredPodcasts = podcasts.filter { podcast -> Bool in
            return podcast.trackName != podcast.trackName && podcast.artistName != podcast.artistName
        }
        
        let data = try! NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }

    func deletePodcast(at index: Int) {
        var podcasts = savedPodcasts
        podcasts.remove(at: index)

        let data = try! NSKeyedArchiver.archivedData(withRootObject: podcasts, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }

    func downloadEpisode(_ episode: Episode) {
        do {
            var episodes = downloadedEpisodes
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeError {
            print("\n\t\tFailed to encode episode:", encodeError)
        }
    }

    func deleteEpisode(at index: Int) {
        var savedEpisodes = downloadedEpisodes
        savedEpisodes.remove(at: index)

        do {
            let data = try JSONEncoder().encode(savedEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeError {
            print("\n\t\tFailed to encode episode:", encodeError)
        }
    }

    func deleteEpisode(_ episode: Episode) {
        let savedEpisodes = downloadedEpisodes
        let filteredEpisodes = savedEpisodes.filter { filteredEpisode -> Bool in
            return filteredEpisode.title != episode.title
        }

        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeError {
            print("\n\t\tFailed to encode episode:", encodeError)
        }
    }
}

