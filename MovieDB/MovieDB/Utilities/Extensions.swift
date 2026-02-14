//
//  Extensions.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let appBackground = Color(UIColor.systemBackground)
    static let appSecondaryBackground = Color(UIColor.secondarySystemBackground)
}

// MARK: - View Extensions
extension View {
    /// Applies a standard card style
    func cardStyle() -> some View {
        self
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
