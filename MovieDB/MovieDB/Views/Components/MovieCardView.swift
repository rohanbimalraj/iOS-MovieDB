//
//  MovieCardView.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import SwiftUI
import Kingfisher

struct MovieCardView: View {
    
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster Image
            ZStack(alignment: .topTrailing) {
                KFImage(movie.posterURL)
                    .placeholder { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 240)
                            .overlay {
                                ProgressView()
                            }
                    }
                    .onFailure { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 240)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(12)
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Movie Info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(movie.formattedRating)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // Year
                    Text(movie.releaseYear)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    MovieCardView(
        movie: Movie(
            id: 1,
            title: "Sample Movie",
            originalTitle: "Sample Movie",
            overview: "This is a sample movie overview",
            posterPath: "/sample.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2024-01-01",
            voteAverage: 7.5,
            voteCount: 1000,
            popularity: 100.0,
            adult: false,
            video: false,
            genreIds: [28, 12]
        ),
        isFavorite: false,
        onFavoriteToggle: {}
    )
    .frame(width: 180)
    .padding()
}
