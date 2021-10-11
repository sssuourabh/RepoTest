//
//  ImageCache.swift
//  RepoTest
//
//  Created by Sourabh Singh on 10/10/21.
//

import UIKit
import ImageIO

/*
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

 */
protocol ImageCacheType: AnyObject {
    func image(for url: URL) -> UIImage?
    func insertImage(_ image: UIImage?, for url: URL)
    func removeImage(for url: URL)
    func removeAllImages()
}

final class ImageCache: ImageCacheType {
    private let config: Config

    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        return cache
    }()
    
    struct Config {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 1024) //100MB
    }
    
    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
    
    func image(for url: URL) -> UIImage? {
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return image
        }
        return nil
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        imageCache.setObject(image, forKey: url as AnyObject, cost: 1)
    }
    
    func removeImage(for url: URL) {
        imageCache.removeObject(forKey: url as AnyObject)
    }
    
    func removeAllImages() {
        imageCache.removeAllObjects()
    }
    
    subscript(_ key: URL) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
    
}
