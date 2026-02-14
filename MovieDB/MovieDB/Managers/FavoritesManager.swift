//
//  FavoritesManager.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation
import Combine

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteMovieIds: Set<Int> = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = Constants.favoritesKey
    
    private init() {
        loadFavorites()
    }
    
    // Load favorites from UserDefaults
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            favoriteMovieIds = ids
        }
    }
    
    // Save favorites to UserDefaults
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteMovieIds) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
    
    // Add movie to favorites
    func addFavorite(_ movieId: Int) {
        favoriteMovieIds.insert(movieId)
        saveFavorites()
    }
    
    // Remove movie from favorites
    func removeFavorite(_ movieId: Int) {
        favoriteMovieIds.remove(movieId)
        saveFavorites()
    }
    
    // Toggle favorite status
    func toggleFavorite(_ movieId: Int) {
        if isFavorite(movieId) {
            removeFavorite(movieId)
        } else {
            addFavorite(movieId)
        }
    }
    
    // Check if movie is favorite
    func isFavorite(_ movieId: Int) -> Bool {
        return favoriteMovieIds.contains(movieId)
    }
    
    // Get all favorites
    func getAllFavorites() -> Set<Int> {
        return favoriteMovieIds
    }
    
    // Clear all favorites
    func clearAllFavorites() {
        favoriteMovieIds.removeAll()
        saveFavorites()
    }
}
