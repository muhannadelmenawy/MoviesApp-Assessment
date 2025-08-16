//
//  MoviesAppTests.swift
//  MoviesAppTests
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import XCTest
@testable import MoviesApp

final class MoviesAppTests: XCTestCase {

    func testExample() throws {
        XCTAssertTrue(1 + 1 == 2)
    }

    func testMovieModelParsing() throws {
        let json = """
        {
            "id": 123,
            "title": "Inception",
            "release_date": "2010-07-16",
            "poster_path": "/qwerty.jpg"
        }
        """.data(using: .utf8)!

        let movie = try JSONDecoder().decode(Movie.self, from: json)
        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Inception")
        XCTAssertEqual(movie.releaseDate, "2010-07-16")
        XCTAssertEqual(movie.posterPath, "/qwerty.jpg")
    }
}
