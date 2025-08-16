//
//  MoviesRepository.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation
import Combine

protocol MoviesRepositoryType {
    func fetchGenres(forceRemote: Bool) -> AnyPublisher<[Genre], Never>
    func fetchTrending(page: Int, forceRemote: Bool) -> AnyPublisher<PagedResponse<Movie>?, Never>
    func fetchDetails(id: Int, forceRemote: Bool) -> AnyPublisher<MovieDetails?, Never>
}

final class MoviesRepository: MoviesRepositoryType {
    private let service: TMDBServiceType
    private let cache: DiskCacheType

    init(service: TMDBServiceType = TMDBService(), cache: DiskCacheType = DiskCache()) {
        self.service = service
        self.cache = cache
    }

    private func genresFile() -> String { "genres.json" }
    private func trendingFile(page: Int) -> String { "trending_page_\(page).json" }
    private func detailsFile(id: Int) -> String { "movie_\(id).json" }

    func fetchGenres(forceRemote: Bool) -> AnyPublisher<[Genre], Never> {
        let local: [Genre] = (try? cache.load([Genre].self, from: genresFile())) ?? []
        guard forceRemote || local.isEmpty else { return Just(local).eraseToAnyPublisher() }

        return service.genres()
            .map { [weak self] g in try? self?.cache.save(g, as: self?.genresFile() ?? "genres.json"); return g }
            .replaceError(with: local)
            .eraseToAnyPublisher()
    }

    func fetchTrending(page: Int, forceRemote: Bool) -> AnyPublisher<PagedResponse<Movie>?, Never> {
        let local: PagedResponse<Movie>? = try? cache.load(PagedResponse<Movie>.self, from: trendingFile(page: page))
        guard forceRemote || local == nil else { return Just(local).eraseToAnyPublisher() }

        return service.trending(page: page)
            .map { [weak self] r in try? self?.cache.save(r, as: self?.trendingFile(page: page) ?? ""); return r }
            .map(Optional.init)
            .replaceError(with: local)
            .eraseToAnyPublisher()
    }

    func fetchDetails(id: Int, forceRemote: Bool) -> AnyPublisher<MovieDetails?, Never> {
        let local: MovieDetails? = try? cache.load(MovieDetails.self, from: detailsFile(id: id))
        guard forceRemote || local == nil else { return Just(local).eraseToAnyPublisher() }

        return service.details(id: id)
            .map { [weak self] d in try? self?.cache.save(d, as: self?.detailsFile(id: id) ?? ""); return d }
            .map(Optional.init)
            .replaceError(with: local)
            .eraseToAnyPublisher()
    }
}
