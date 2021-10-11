//
//  Scheduler.swift
//  RepoTest
//
//  Created by Sourabh Singh on 10/10/21.
//

import Foundation
import Combine

final class Scheduler {
    static var backgroundScheduler: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()
    
    static let mainScheduler = RunLoop.main

}
