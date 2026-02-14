//
//  Video.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - Videos Response
struct VideosResponse: Codable {
    let id: Int
    let results: [Video]
}

// MARK: - Video Model
struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool
    let publishedAt: String
    let size: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, key, name, site, type, official, size
        case publishedAt = "published_at"
    }
    
    // Check if this is an official YouTube trailer
    var isOfficialYouTubeTrailer: Bool {
        return site.lowercased() == "youtube" && 
               type.lowercased() == "trailer" && 
               official
    }
    
    // Get YouTube URL
    var youtubeURL: URL? {
        guard site.lowercased() == "youtube" else { return nil }
        return Constants.youtubeURL(for: key)
    }
    
    // Get YouTube thumbnail URL
    var thumbnailURL: URL? {
        guard site.lowercased() == "youtube" else { return nil }
        return URL(string: "\(Constants.youtubeThumbnailURL)\(key)/hqdefault.jpg")
    }
}
