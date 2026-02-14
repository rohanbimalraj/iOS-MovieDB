//
//  MovieDetailViewModel.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - Movie Detail View Model
@MainActor
class MovieDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var movieDetail: MovieDetail?
    @Published var trailer: Video?
    @Published var cast: [CastMember] = []
    @Published var directors: [CrewMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasError: Bool = false
    
    // MARK: - Private Properties
    private let tmdbService: TMDbService
    private let favoritesManager: FavoritesManager
    private let movieId: Int
    
    // MARK: - Initialization
    init(movieId: Int, tmdbService: TMDbService = TMDbService(), favoritesManager: FavoritesManager = .shared) {
        self.movieId = movieId
        self.tmdbService = tmdbService
        self.favoritesManager = favoritesManager
    }
    
    // MARK: - Load Movie Details
    func loadMovieDetails() async {
        isLoading = true
        hasError = false
        errorMessage = nil
        
        await withTaskGroup(of: Void.self) { group in
            // Fetch movie details
            group.addTask {
                await self.fetchMovieDetails()
            }
            
            // Fetch videos
            group.addTask {
                await self.fetchMovieVideos()
            }
            
            // Fetch credits
            group.addTask {
                await self.fetchMovieCredits()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Movie Details
    private func fetchMovieDetails() async {
        do {
            movieDetail = try await tmdbService.fetchMovieDetails(id: movieId)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Fetch Movie Videos
    private func fetchMovieVideos() async {
        do {
            let response = try await tmdbService.fetchMovieVideos(id: movieId)
            // Filter for official YouTube trailers only
            let trailers = response.results.filter { $0.isOfficialYouTubeTrailer }
            trailer = trailers.first // Get the first official trailer
        } catch {
            // Non-critical error, just log it
            print("Failed to fetch videos: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Movie Credits
    private func fetchMovieCredits() async {
        do {
            let response = try await tmdbService.fetchMovieCredits(id: movieId)
            // Get first 10 cast members
            cast = Array(response.cast.prefix(10))
            // Filter directors only
            directors = response.crew.filter { $0.isDirector }
        } catch {
            // Non-critical error, just log it
            print("Failed to fetch credits: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Favorites
    func isFavorite() -> Bool {
        return favoritesManager.isFavorite(movieId)
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(movieId)
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        hasError = true
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Retry
    func retry() {
        Task {
            await loadMovieDetails()
        }
    }
}
