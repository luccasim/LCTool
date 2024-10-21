//
//  FreeAnalytics.swift
//  Mon Compte Free
//
//  Created by Free on 04/10/2022.
//

#if PROD
import FirebaseAnalytics
#endif
import Foundation

public final class FreeAnalyticsManager: ObservableObject {
    
    static let shared = FreeAnalyticsManager()
    init() {}
    
    func log(name: String, parameters: [String: Any]? = nil) {
        #if PROD
        Analytics.logEvent(name + action.rawValue, parameters: parameters)
        #endif
    }
        
    func userProperty(value: String, key: String) {
        #if PROD
        Analytics.setUserProperty(value, forName: key)
        #endif
    }
    
}
