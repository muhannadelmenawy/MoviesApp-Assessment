//
//  MoviesRepositoryTests.swift
//  MoviesAppTests
//
//  Created by Muhannad El Menawy on 16/08/2025.
//

import XCTest
import Combine
@testable import MoviesApp

final class MoviesRepositoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private var service: MockTMDBService!
    private var cache: MockDiskCache!
    private var repo: MoviesRepository!

    override func setUp() {
        super.setUp()
        service = MockTMDBService()
        cache = MockDiskCache()
        repo = MoviesRepository(service: service, cache: cache)
    }

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testGenres_fetchesRemoteAndCaches() {
        // given
        let expected = [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Comedy")]
        service.stubGenres = expected

        // when
        let exp = expectation(description: "genres")
        repo.fetchGenres(forceRemote: true)
            .sink { genres in
                // then
                XCTAssertEqual(genres, expected)
                // cache got written
                let cached: [Genre]? = try? self.cache.load([Genre].self, from: "genres.json")
                XCTAssertEqual(cached, expected)
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    func testTrending_usesCacheWhenOffline() {
        // given: cache has a page
        let page1 = PagedResponse(page: 1,
                                  results: [Movie(id: 101, title: "Cached Movie", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [1])],
                                  totalPages: 1, totalResults: 1)
        try? cache.save(page1, as: "trending_page_1.json")

        // and: service fails (simulate offline)
        service.trendingError = .status(503)

        // when
        let exp = expectation(description: "trending")
        repo.fetchTrending(page: 1, forceRemote: false)
            .sink { response in
                // then (falls back to cache)
                XCTAssertEqual(response?.results.first?.title, "Cached Movie")
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    func testDetails_fetchesAndCaches() {
        // given
        let details = MovieDetails(
            id: 7, title: "Seven", posterPath: nil, releaseDate: "1995-09-22",
            genres: [Genre(id: 80, name: "Crime")],
            overview: "overview", homepage: "https://example.com",
            budget: 100, revenue: 200, spokenLanguages: [],
            status: "Released", runtime: 123
        )
        service.stubDetails = details

        // when
        let exp = expectation(description: "details")
        repo.fetchDetails(id: 7, forceRemote: true)
            .sink { d in
                // then
                XCTAssertEqual(d?.id, 7)
                let cached: MovieDetails? = try? self.cache.load(MovieDetails.self, from: "movie_7.json")
                XCTAssertEqual(cached?.title, "Seven")
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}

// MARK: - Test doubles

private final class MockTMDBService: TMDBServiceType {
    var stubGenres: [Genre]?
    var trendingError: APIError?
    var stubTrending: PagedResponse<Movie>?
    var stubDetails: MovieDetails?

    func genres() -> AnyPublisher<[Genre], APIError> {
        if let stubGenres { return Just(stubGenres).setFailureType(to: APIError.self).eraseToAnyPublisher() }
        return Fail(error: .status(404)).eraseToAnyPublisher()
    }

    func trending(page: Int) -> AnyPublisher<PagedResponse<Movie>, APIError> {
        if let trendingError { return Fail(error: trendingError).eraseToAnyPublisher() }
        if let stubTrending { return Just(stubTrending).setFailureType(to: APIError.self).eraseToAnyPublisher() }
        // default: one result
        let fallback = PagedResponse(page: page,
                                     results: [Movie(id: 1, title: "A", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [1])],
                                     totalPages: 1, totalResults: 1)
        return Just(fallback).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func details(id: Int) -> AnyPublisher<MovieDetails, APIError> {
        if let stubDetails { return Just(stubDetails).setFailureType(to: APIError.self).eraseToAnyPublisher() }
        return Fail(error: .status(404)).eraseToAnyPublisher()
    }
}

private final class MockDiskCache: DiskCacheType {
    private var store: [String: Data] = [:]

    func save<T: Encodable>(_ value: T, as filename: String) throws {
        store[filename] = try JSONEncoder().encode(value)
    }

    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let data = store[filename] else {
            throw NSError(domain: "NoFile", code: 1)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
