//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movieId: Int
    
    @StateObject private var viewModel: MovieDetailViewModel
    @StateObject private var favoritesManager = FavoritesManager.shared
    @Environment(\.dismiss) private var dismiss
    
    init(movieId: Int) {
        self.movieId = movieId
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.movieDetail == nil {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else if let movie = viewModel.movieDetail {
                movieDetailContent(movie: movie)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMovieDetails()
        }
    }
    
    // MARK: - Movie Detail Content
    private func movieDetailContent(movie: MovieDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Backdrop & Poster
                backdropSection(movie: movie)
                
                // Title & Basic Info
                titleSection(movie: movie)
                
                // Trailer
                if let trailer = viewModel.trailer {
                    trailerSection(trailer: trailer)
                }
                
                // Overview
                overviewSection(movie: movie)
                
                // Genres
                genresSection(movie: movie)
                
                // Directors
                if !viewModel.directors.isEmpty {
                    directorsSection()
                }
                
                // Cast
                if !viewModel.cast.isEmpty {
                    castSection()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Backdrop Section
    private func backdropSection(movie: MovieDetail) -> some View {
        ZStack(alignment: .bottom) {
            // Backdrop Image
            GeometryReader { geometry in
                AsyncImage(url: movie.backdropURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(height: 300)
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            // Poster
            HStack(alignment: .bottom, spacing: 16) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 100, height: 150)
                .clipped()
                .cornerRadius(12)
                .shadow(radius: 10)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Title Section
    private func titleSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let tagline = movie.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Favorite Button
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: favoritesManager.isFavorite(movieId) ? "heart.fill" : "heart")
                        .font(.system(size: 28))
                        .foregroundColor(favoritesManager.isFavorite(movieId) ? .red : .gray)
                }
                .padding(.leading, 8)
            }
            
            // Metadata
            HStack(spacing: 16) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .fontWeight(.semibold)
                }
                
                // Year
                Text(movie.releaseYear)
                    .foregroundColor(.secondary)
                
                // Runtime
                if let runtime = movie.runtime, runtime > 0 {
                    Text(movie.formattedRuntime)
                        .foregroundColor(.secondary)
                }
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Trailer Section
    private func trailerSection(trailer: Video) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trailer")
                .font(.headline)
                .padding(.horizontal)
            
            if let url = trailer.youtubeURL {
                Link(destination: url) {
                    ZStack {
                        // YouTube Thumbnail
                        AsyncImage(url: trailer.thumbnailURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(16/9, contentMode: .fit)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                        
                        // Play Button Overlay
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Overview Section
    private func overviewSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            
            Text(movie.overview)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Genres Section
    private func genresSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Genres")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(movie.genres) { genre in
                        Text(genre.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Directors Section
    private func directorsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Director\(viewModel.directors.count > 1 ? "s" : "")")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.directors) { director in
                        VStack(spacing: 8) {
                            AsyncImage(url: director.profileURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .empty, .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            
                            Text(director.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Cast Section
    private func castSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.cast) { castMember in
                        VStack(spacing: 8) {
                            AsyncImage(url: castMember.profileURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .empty, .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            
                            VStack(spacing: 2) {
                                Text(castMember.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                
                                Text(castMember.character)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 80)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading movie details...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Failed to load movie details")
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
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: 840464)
    }
}
