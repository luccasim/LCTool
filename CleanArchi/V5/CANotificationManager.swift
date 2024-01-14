//
//  CANotificationManager.swift
//  Mon Compte Free
//
//  Created by Free on 10/11/2023.
//

import Foundation

protocol CANotificationProtocol {
    func post(id: String, value: Any?)
//    func alert(type: CANotificationManager.AlertType)
}

final class CANotificationManager: CANotificationProtocol {
    
    static var shared = CANotificationManager()
    
    enum AlertType: String {
        case networkIssue
        case webserviceIssue
    }
    
//    func alert(type: AlertType) {
//        var alert: AlertToast.Id = .system(title: "")
//        switch type {
//        case .networkIssue:
//            alert = .system(title: "AlertToast.NetworkIssue.Title",
//                            image: .system(name: "exclamationmark.circle.fill"))
//        case .webserviceIssue:
//            alert = .system(title: "AlertToast.WebserviceIssue.Title",
//                            image: .system(name: "exclamationmark.circle.fill"))
//        }
//        post(id: "alert", value: alert)
//    }
    
    func post(id: String, value: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init(id), object: value)
        }
    }
}
