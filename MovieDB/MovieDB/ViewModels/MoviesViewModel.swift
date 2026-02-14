//
//  MoviesViewModel.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation
import Combine

// MARK: - Movies View Model
@MainActor
class MoviesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var movies: [Movie] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasError: Bool = false
    
    // MARK: - Private Properties
    private let tmdbService: TMDbService
    private let favoritesManager: FavoritesManager
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(tmdbService: TMDbService = TMDbService(), favoritesManager: FavoritesManager = .shared) {
        self.tmdbService = tmdbService
        self.favoritesManager = favoritesManager
        
        setupSearchDebounce()
        loadPopularMovies()
    }
    
    // MARK: - Search Debounce
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.handleSearchQueryChange(query)
            }
            .store(in: &cancellables)
    }
    
    private func handleSearchQueryChange(_ query: String) {
        searchTask?.cancel()
        
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            loadPopularMovies()
        } else {
            searchMovies(query: query)
        }
    }
    
    // MARK: - Load Popular Movies
    func loadPopularMovies() {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            hasError = false
            errorMessage = nil
            
            do {
                let response = try await tmdbService.fetchPopularMovies()
                if !Task.isCancelled {
                    movies = response.results
                }
            } catch {
                if !Task.isCancelled {
                    handleError(error)
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    // MARK: - Search Movies
    private func searchMovies(query: String) {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            hasError = false
            errorMessage = nil
            
            do {
                let response = try await tmdbService.searchMovies(query: query)
                if !Task.isCancelled {
                    movies = response.results
                }
            } catch {
                if !Task.isCancelled {
                    handleError(error)
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    // MARK: - Favorites
    func isFavorite(_ movieId: Int) -> Bool {
        return favoritesManager.isFavorite(movieId)
    }
    
    func toggleFavorite(_ movieId: Int) {
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
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            loadPopularMovies()
        } else {
            searchMovies(query: searchQuery)
        }
    }
}
