//
//  PagedResponse.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

struct PagedResponse<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
