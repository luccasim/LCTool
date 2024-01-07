//
//  CAUsecaseOption.swift
//  Mon Compte Free
//
//  Created by Free on 17/11/2023.
//

import Foundation

enum CAUsecaseOption: Equatable {
    /// disable .webServiceIssue, .notFound, .networkIssue
    case disableSnackBar
    
    /// disable ReachabilityManager
    case disableReachability
    
    /// disable NotificationCenter.default.post
    case disableNotificationCenter
    
    /// use cache on repository dataTask, (limit in seconds), you should set this option for set AND retrieve the cached data.
    case useCache(limit: Double)
    
    /// task on repository will use testUIServer
    case useTestUIServer(mock: String)
}
