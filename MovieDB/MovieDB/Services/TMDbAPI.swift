//
//  TMDbAPI.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - TMDb API Endpoints
enum TMDbAPI {
    case popularMovies(page: Int)
    case searchMovies(query: String, page: Int)
    case movieDetails(id: Int)
    case movieVideos(id: Int)
    case movieCredits(id: Int)
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .searchMovies:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .movieVideos(let id):
            return "/movie/\(id)/videos"
        case .movieCredits(let id):
            return "/movie/\(id)/credits"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .popularMovies(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .movieDetails, .movieVideos, .movieCredits:
            return nil
        }
    }
}

// MARK: - TMDb Service Protocol
protocol TMDbServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MoviesResponse
    func searchMovies(query: String, page: Int) async throws -> MoviesResponse
    func fetchMovieDetails(id: Int) async throws -> MovieDetail
    func fetchMovieVideos(id: Int) async throws -> VideosResponse
    func fetchMovieCredits(id: Int) async throws -> CreditsResponse
}

// MARK: - TMDb Service
class TMDbService: TMDbServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // Fetch popular movies
    func fetchPopularMovies(page: Int = 1) async throws -> MoviesResponse {
        let endpoint = TMDbAPI.popularMovies(page: page)
        return try await networkService.fetch(from: endpoint.path, queryItems: endpoint.queryItems)
    }
    
    // Search movies
    func searchMovies(query: String, page: Int = 1) async throws -> MoviesResponse {
        guard !query.isEmpty else {
            throw NetworkError.invalidURL
        }
        let endpoint = TMDbAPI.searchMovies(query: query, page: page)
        return try await networkService.fetch(from: endpoint.path, queryItems: endpoint.queryItems)
    }
    
    // Fetch movie details
    func fetchMovieDetails(id: Int) async throws -> MovieDetail {
        let endpoint = TMDbAPI.movieDetails(id: id)
        return try await networkService.fetch(from: endpoint.path, queryItems: endpoint.queryItems)
    }
    
    // Fetch movie videos
    func fetchMovieVideos(id: Int) async throws -> VideosResponse {
        let endpoint = TMDbAPI.movieVideos(id: id)
        return try await networkService.fetch(from: endpoint.path, queryItems: endpoint.queryItems)
    }
    
    // Fetch movie credits
    func fetchMovieCredits(id: Int) async throws -> CreditsResponse {
        let endpoint = TMDbAPI.movieCredits(id: id)
        return try await networkService.fetch(from: endpoint.path, queryItems: endpoint.queryItems)
    }
}
