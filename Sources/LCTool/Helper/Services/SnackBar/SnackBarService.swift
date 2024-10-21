//
//  SnackBarService.swift
//  Mon Compte Free
//
//  Created by Free on 16/10/2024.
//

import Foundation
import SwiftUI

public final class SnackBarService {
    
}

//extension SnackBarService: FreeSnackBarProtocol {
//    
//    func show(type: FreeSnackBarType, title: LocalizedStringKey, message: LocalizedStringKey) {
//        var alert: AlertToast.Id {
//            switch type {
//            case .networkIssue:
//                return .system(title: "AlertToast.NetworkIssue.Title", image: .system(name: "exclamationmark.circle.fill"))
//            case .webserviceIssue:
//                return .system(title: "AlertToast.WebserviceIssue.Title", image: .system(name: "exclamationmark.circle.fill"))
//            case .success:
//                return .success(title: title, subtitle: message)
//            case .warning:
//                return .warning(title: title, subtitle: message)
//            case .error:
//                return .error(title: title, subtitle: message)
//            }
//        }
//        
//        NotificationCenter.post(id: "alert", value: alert)
//    }
//}
