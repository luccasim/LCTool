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

final class FreeAnalyticsManager: ObservableObject {
    
    static let shared = FreeAnalyticsManager()
    init() {}
    
    func log(name: EventKey, action: Action, parameters: [String: Any]? = nil) {
        #if PROD
        Analytics.logEvent(name.rawValue + action.rawValue, parameters: parameters)
        #else
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init("loggerService"),
                                            object: ("analytics", ["event": name.rawValue, "action": action.rawValue]))
        }
        #endif
    }
    
    func log(name: String, action: Action, parameters: [String: Any]? = nil) {
        #if PROD
        Analytics.logEvent(name + action.rawValue, parameters: parameters)
        #else
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init("loggerService"),
                                            object: ("analytics", ["event": name, "action": action.rawValue]))
        }
        #endif
    }
        
    func userProperty(box: Box) {
        #if PROD
        Analytics.setUserProperty(box.rawValue, forName: "freebox_type")
        #endif
    }
}

extension FreeAnalyticsManager: FreeAnalyticsProtocol {
    func log(name: EventKey, action: Action) {
        self.log(name: name, action: action, parameters: nil)
    }
}
