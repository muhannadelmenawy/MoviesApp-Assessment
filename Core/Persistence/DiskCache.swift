//
//  DiskCache.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation

protocol DiskCacheType {
    func save<T: Encodable>(_ value: T, as filename: String) throws
    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T
}

final class DiskCache: DiskCacheType {
    private let folderURL: URL
    private let fm = FileManager.default

    init(folderName: String = "DiskCache") {
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        folderURL = base.appendingPathComponent(folderName, isDirectory: true)
        try? fm.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }

    func save<T: Encodable>(_ value: T, as filename: String) throws {
        let url = folderURL.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: .atomic)
    }

    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = folderURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
