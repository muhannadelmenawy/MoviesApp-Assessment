//
//  TMDBService.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation
import Combine

protocol TMDBServiceType {
    func genres() -> AnyPublisher<[Genre], APIError>
    func trending(page: Int) -> AnyPublisher<PagedResponse<Movie>, APIError>
    func details(id: Int) -> AnyPublisher<MovieDetails, APIError>
}

final class TMDBService: TMDBServiceType {
    private let client: APIClientType
    init(client: APIClientType = APIClient()) { self.client = client }

    func genres() -> AnyPublisher<[Genre], APIError> {
        client.request(TMDBEndpoint.genres).map(\GenresResponse.genres).eraseToAnyPublisher()
    }
    func trending(page: Int) -> AnyPublisher<PagedResponse<Movie>, APIError> {
        client.request(TMDBEndpoint.trending(page: page))
    }
    func details(id: Int) -> AnyPublisher<MovieDetails, APIError> {
        client.request(TMDBEndpoint.details(id: id))
    }
}
