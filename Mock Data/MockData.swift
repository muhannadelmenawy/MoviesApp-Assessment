//
//  MockData.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 16/08/2025.
//

import Foundation

// Mock Genre Data
struct MockData {

    static let genres: [Genre] = [
        Genre(id: 1, name: "Action"),
        Genre(id: 2, name: "Comedy"),
        Genre(id: 3, name: "Drama"),
        Genre(id: 4, name: "Horror"),
        Genre(id: 5, name: "Romance"),
        Genre(id: 6, name: "Sci-Fi")
    ]

    // For Preview Purposes
    static let previewMovie: Movie = Movie(id: 1, title: "Mock Movie", posterPath: "/mock.jpg", releaseDate: "2023-08-01", genreIDs: [1, 2])
    static let previewGenre: Genre = Genre(id: 1, name: "Action")

}
