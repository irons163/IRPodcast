//
//  Podcast.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import Foundation

final class Podcast: NSObject, Decodable, NSCoding {

    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?

    func encode(with aCoder: NSCoder) {
        print("\n\t\tTrying to transform Podcast into Data")
        aCoder.encode(trackName ?? "", forKey: Keys.trackNameKey)
        aCoder.encode(artistName ?? "", forKey: Keys.artistNameKey)
        aCoder.encode(artworkUrl600 ?? "", forKey: Keys.artworkKey)
        aCoder.encode(feedUrl ?? "", forKey: Keys.feedKey)
    }

    init?(coder aDecoder: NSCoder) {
        print("\n\t\tTrying to turn Data into Podcast")
        self.trackName     = aDecoder.decodeObject(forKey: Keys.trackNameKey) as? String
        self.artistName    = aDecoder.decodeObject(forKey: Keys.artistNameKey) as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: Keys.artworkKey) as? String
        self.feedUrl       = aDecoder.decodeObject(forKey: Keys.feedKey) as? String
    }

}

private extension Podcast {

    enum Keys {
        static let trackNameKey  = "trackNameKey"
        static let artistNameKey = "artistNameKey"
        static let artworkKey    = "artworkKey"
        static let feedKey       = "feedKey"
    }

}

