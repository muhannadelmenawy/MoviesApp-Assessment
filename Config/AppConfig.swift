//
//  AppConfig.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

enum AppConfig {
    static let apiKey: String = "d42ffa5ae87ea20e5b5b03d94b0bd94a"

    static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p")!
    static let defaultLanguage = "en-US"
    
    static func posterURL(path: String?, size: String = "w500") -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return imageBaseURL.appendingPathComponent(size).appendingPathComponent(trimmed)
    }
}
