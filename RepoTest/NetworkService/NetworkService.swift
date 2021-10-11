//
//  NetworkService.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation
import Combine

final class NetworkService: NetworkServiceType {

    private let session: URLSession
    
    init(session: URLSession = URLSession.init(configuration: .default)) {
        self.session = session
    }
    
    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> where T : Decodable {
        guard let request = resource.request else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidRequest }
            .print()
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return .fail(NetworkError.invalidResponse)
                }

                guard 200..<300 ~= response.statusCode else {
                    return .fail(NetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
                }
                return .just(data)
            }
            .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}

/*
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
 */

/*
 
 struct Resource<T: Decodable> {
     let url: URL
     let parameters: [String: CustomStringConvertible]
     
     var request: URLRequest? {
         guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
             return nil
         }
         components.queryItems = parameters.keys.map { key in
             URLQueryItem(name: key, value: parameters[key]?.description)
         }
         
         guard let url = components.url else {
             return nil
         }
         return URLRequest(url: url)
     }
     
     init(url: URL, parameters: [String: CustomStringConvertible] = [:]) {
         self.url = url
         self.parameters = parameters
     }
 }

 */
