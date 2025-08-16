//
//  Endpoint.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

enum TMDBEndpoint: Endpoint {
    case genres
    case trending(page: Int)
    case details(id: Int)
    
    var path: String {
        switch self {
        case .genres: return "/genre/movie/list"
        case .trending: return "/discover/movie"
        case .details(let id): return "/movie/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .genres:
            return [ .init(name: "language", value: AppConfig.defaultLanguage) ]
        case .trending(let page):
            return [
                .init(name: "include_adult", value: "false"),
                .init(name: "sort_by", value: "popularity.desc"),
                .init(name: "page", value: String(page)),
                .init(name: "language", value: AppConfig.defaultLanguage)
            ]
        case .details:
            return [ .init(name: "language", value: AppConfig.defaultLanguage) ]
        }
    }
}
