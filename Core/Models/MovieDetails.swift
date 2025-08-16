//
//  MovieDetails.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

struct MovieDetails: Codable, Identifiable {
    struct SpokenLanguage: Codable, Identifiable, Hashable {
        let englishName: String?
        let iso6391: String?
        let name: String?
        var id: String { iso6391 ?? englishName ?? name ?? UUID().uuidString }
        enum CodingKeys: String, CodingKey {
            case englishName = "english_name"; case iso6391 = "iso_639_1"; case name
        }
    }

    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let genres: [Genre]?
    let overview: String?
    let homepage: String?
    let budget: Int?
    let revenue: Int?
    let spokenLanguages: [SpokenLanguage]?
    let status: String?
    let runtime: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, genres, overview, homepage, budget, revenue, status, runtime
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case spokenLanguages = "spoken_languages"
    }

    var yearMonthString: String {
        guard let d = Formatters.parseDate(releaseDate) else { return "—" }
        return Formatters.yearMonth.string(from: d)
    }
}
