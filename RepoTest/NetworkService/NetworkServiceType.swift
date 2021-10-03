//
//  NetworkServiceType.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation
import Combine

protocol NetworkServiceType: AnyObject {
    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error>
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
}
