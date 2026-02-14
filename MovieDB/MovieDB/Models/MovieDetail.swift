//
//  MovieDetail.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - Movie Detail Model
struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool
    let video: Bool
    let runtime: Int?
    let genres: [Genre]
    let homepage: String?
    let imdbId: String?
    let status: String?
    let tagline: String?
    let budget: Int?
    let revenue: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video
        case runtime, genres, homepage, status, tagline, budget, revenue
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case imdbId = "imdb_id"
    }
    
    // Computed Properties
    var posterURL: URL? {
        Constants.posterURL(for: posterPath)
    }
    
    var backdropURL: URL? {
        Constants.backdropURL(for: backdropPath)
    }
    
    var releaseYear: String {
        guard !releaseDate.isEmpty else { return "N/A" }
        return String(releaseDate.prefix(4))
    }
    
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    var formattedRuntime: String {
        guard let runtime = runtime, runtime > 0 else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var genresString: String {
        genres.map { $0.name }.joined(separator: ", ")
    }
}

// MARK: - Genre Model
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}
