//
//  Report+CleanArchi.swift
//  Mon Compte Free
//
//  Created by Free on 02/08/2023.
//

import Foundation
import UserNotifications

protocol CAReportProtocol {
    func sendDecodableStrapi(request: URLRequest, error: Error, json: Data) async
    func pushLocalError(caError: CAError, className: String)
}

/// This class need register a host for send a report
/// use .sendReport()
final class CAReportManager: ObservableObject, CAReportProtocol {
    
    static var shared = CAReportManager()
    
    @Published var shouldActiveSystemNotification = false
    private var path: String?
    var forceMail: Bool?
    
    // Testing
    var trackerSender: Bool?
    var enableSession = true
    
    func registerServer(path: String) {
        self.path = path
    }
    
    // MARK: - Local Notification
    
    func checkSystemNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            DispatchQueue.main.async {
                self.shouldActiveSystemNotification = !(setting.authorizationStatus == .authorized)
            }
        }
    }
    
    func pushLocalError(caError: CAError, className: String) {
        let content = UNMutableNotificationContent()
        
        switch caError {
        case .missingData:
            content.subtitle = "Missing Stored Value"
        case .missingDTO:
            content.subtitle = "Missing DTO Input Value"
        case .requestCreate:
            content.subtitle = "Fail to create request"
        default:
            break
        }

        content.title = className.replacingOccurrences(of: ".Type", with: "")
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        debug("[CAReport]: \(className) => \(content.subtitle)")
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Decodable Strapi
    
    func sendDecodableStrapi(request: URLRequest, error: Error, json: Data) async {
        trackerSender = nil
        
        guard let path = self.path else {
            return
        }
        
        let str = String(data: json, encoding: .utf8)?.components(separatedBy: "\n")
        let report = Report(request: request, error: error, json: str, force: self.forceMail ?? false)
        let body = try? JSONEncoder().encode(report)
        
//        guard let reportRequest = URLRequest(path: path, httpMethod: .post, bodyForm: .json(body)) else {
//            return
//        }
//        
//        if enableSession {
//            _ = try? await URLSession.shared.data(for: reportRequest)
//        }
//        
//        trackerSender = true
    }
    
    private struct Report: Codable {
        
        let data: Data
        
        struct Data: Codable {
            let title: String?
            let content: Content?
            let platform: String?
            var force: Bool?
            var debug: Bool?
            
            struct Content: Codable {
                var url, curl, key, error: String?
                var json: [String]?
            }
        }
        
        init(request: URLRequest, error: Error, json: [String]?, force: Bool? = false) {
            var key = ""
            var errorDescription = ""
            
            switch error as? DecodingError {
            case .typeMismatch(_, let value):
                key = value.codingPath.last?.stringValue ?? ""
                errorDescription = value.debugDescription
            default:
                break
            }
            
            let title = request.caDescription?.isEmpty ?? false ? request.caDescription : request.url?.path
            
            self.data = .init(title: title,
                              content: .init(url: request.url?.absoluteString,
                                             curl: request.curlCommand.replacingOccurrences(of: "curl", with: ""),
                                             key: key,
                                             error: errorDescription,
                                             json: json),
                              platform: "iOS",
                              force: force)
        }
    }
}
