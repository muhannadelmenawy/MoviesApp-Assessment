//
//  Movie.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let genreIDs: [Int]?

    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genreIDs = "genre_ids"
    }

    var yearString: String {
        guard let d = Formatters.parseDate(releaseDate) else { return "—" }
        return Formatters.year.string(from: d)
    }
}
