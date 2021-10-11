//
//  ImageLoaderService.swift
//  RepoTest
//
//  Created by Sourabh Singh on 03/10/21.
//

import Foundation
import Combine
import UIKit

protocol ImageLoaderServiceType: AnyObject {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoaderService: ImageLoaderServiceType {

    private let cache: ImageCacheType = ImageCache()
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache.image(for: url) {
            print("fromCache - \(url)")
            return .just(image)
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in return UIImage(data: data) }
            .catch { error in return Just(nil) }
            .handleEvents(receiveOutput: {[unowned self] image in
                guard let image = image else { return }
                self.cache.insertImage(image, for: url)
            })
            .print("Image loading \(url):")
            .eraseToAnyPublisher()
    }
}

//https://developer.apple.com/documentation/uikit/views_and_controls/table_views/asynchronously_loading_images_into_table_and_collection_views

/*
 func loadImage(for movie: Movie, size: ImageSize) -> AnyPublisher<UIImage?, Never> {
     return Deferred { return Just(movie.poster) }
     .flatMap({[unowned self] poster -> AnyPublisher<UIImage?, Never> in
         guard let poster = movie.poster else { return .just(nil) }
         let url = size.url.appendingPathComponent(poster)
         return self.imageLoaderService.loadImage(from: url)
     })
     .subscribe(on: Scheduler.backgroundWorkScheduler)
     .receive(on: Scheduler.mainScheduler)
     .share()
     .eraseToAnyPublisher()
 }
 */
