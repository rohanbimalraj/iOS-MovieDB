//
//  Constants.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

struct Constants {
    // MARK: - API Configuration
    static let apiKey = "f54170f2cadd41837b91ba1c67099283"
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p"
    
    // MARK: - Image Sizes
    static let posterSize = "w500"
    static let backdropSize = "w780"
    static let profileSize = "w185"
    
    // MARK: - YouTube
    static let youtubeBaseURL = "https://www.youtube.com/watch?v="
    static let youtubeThumbnailURL = "https://img.youtube.com/vi/"
    
    // MARK: - User Defaults Keys
    static let favoritesKey = "favoriteMovies"
    
    // MARK: - Helper Methods
    static func posterURL(for path: String?) -> URL? {
        guard let path = path else { return nil }
        return URL(string: "\(imageBaseURL)/\(posterSize)\(path)")
    }
    
    static func backdropURL(for path: String?) -> URL? {
        guard let path = path else { return nil }
        return URL(string: "\(imageBaseURL)/\(backdropSize)\(path)")
    }
    
    static func profileURL(for path: String?) -> URL? {
        guard let path = path else { return nil }
        return URL(string: "\(imageBaseURL)/\(profileSize)\(path)")
    }
    
    static func youtubeURL(for key: String) -> URL? {
        return URL(string: "\(youtubeBaseURL)\(key)")
    }
}
