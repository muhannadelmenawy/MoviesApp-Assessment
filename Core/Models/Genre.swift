//
//  Genre.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct GenresResponse: Codable { let genres: [Genre] }
