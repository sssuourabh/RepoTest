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

/*
 func scrollViewDidScroll(_ scrollView: UIScrollView) {
     if scrollView == feedTableView {
         let contentOffset = scrollView.contentOffset.y
         print("contentOffset: ", contentOffset)
         if (contentOffset > self.lastKnowContentOfsset) {
             print("scrolling Down")
             print("dragging Up")
         } else {
             print("scrolling Up")
             print("dragging Down")
         }
     }
 }

 func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
     if scrollView == feedTableView {
         self.lastKnowContentOfsset = scrollView.contentOffset.y
         print("lastKnowContentOfsset: ", scrollView.contentOffset.y)
     }
 }
 */
