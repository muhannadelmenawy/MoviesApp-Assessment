//
//  ArrayExtension.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 16/08/2025.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
