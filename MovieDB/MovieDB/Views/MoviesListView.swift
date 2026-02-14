//
//  MoviesListView.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import SwiftUI

struct MoviesListView: View {
    
    @StateObject private var viewModel = MoviesViewModel()
    @StateObject private var favoritesManager = FavoritesManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    loadingView
                } else if viewModel.hasError {
                    errorView
                } else if viewModel.movies.isEmpty {
                    emptyView
                } else {
                    moviesGridView
                }
            }
            .navigationTitle("Popular Movies")
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies...")
            .refreshable {
                viewModel.loadPopularMovies()
            }
        }
    }
    
    // MARK: - Movies Grid View
    private var moviesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                        MovieCardView(
                            movie: movie,
                            isFavorite: favoritesManager.isFavorite(movie.id),
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(movie.id)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading movies...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.retry()
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No movies found")
                .font(.headline)
            
            Text("Try searching for something else")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MoviesListView()
}
