//
//  File.swift
//  
//
//  Created by Luc on 14/01/2024.
//

import Foundation
import SwiftUI

// MARK: - Previews

public protocol CAPreviewProtocol {
    var keys: [CAPreviewKey] {get}
    var label: String {get}
    func inject(key: String?)
}

public struct CAPreviewKey: Identifiable {
    let label: String
    let key: String
    
    public var id: String { key }
    public init(label: String, key: String) {
        self.label = label
        self.key = key
    }
}

public protocol PostmanKey {
    var label: String { get }
}

public extension PostmanKey where Self: RawRepresentable {
    var label: String {
        return "\(self.rawValue)"
    }
}

// MARK: - Injected

public protocol CAInjectionKey {

    associatedtype Value

    static var currentValue: Self.Value { get set }
}

public struct CAInjectedValues {
    
    static var current = CAInjectedValues()
    
    public static subscript<K>(key: K.Type) -> K.Value where K: CAInjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    public static subscript<T>(_ keyPath: WritableKeyPath<CAInjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
public struct Injected<T> {
    
    private let keyPath: WritableKeyPath<CAInjectedValues, T>
    
    public var wrappedValue: T {
        get { CAInjectedValues[keyPath] }
        set { CAInjectedValues[keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<CAInjectedValues, T>) {
        self.keyPath = keyPath
    }
}

// MARK: - Reachability

import Network
import SystemConfiguration
import Foundation

public protocol CAReachabilityProtocol {
    func isConnectedToNetwork() -> Bool
}

public final class ReachabilityManager: CAReachabilityProtocol {
        
    public static var shared = ReachabilityManager()
    
    public func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0,
                                      sin_family: 0,
                                      sin_port: 0,
                                      sin_addr: in_addr(s_addr: 0),
                                      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        guard let route = defaultRouteReachability, SCNetworkReachabilityGetFlags(route, &flags) else {
            return false
        }

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
}

// MARK: - Report

import UserNotifications

public protocol CAReportProtocol {
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

        UNUserNotificationCenter.current().add(request)
    }
        
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
            
//            let title = request.caDescription?.isEmpty ?? false ? request.caDescription : request.url?.path
            let title = request.url?.path ?? "\(#function)"
            
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

// MARK: - Notifications

public protocol CANotificationProtocol {
    func post(id: String, value: Any?)
//    func alert(type: CANotificationManager.AlertType)
}

final class CANotificationManager: CANotificationProtocol {
    
    static var shared = CANotificationManager()
    
    enum AlertType: String {
        case networkIssue
        case webserviceIssue
    }
    
    func post(id: String, value: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init(id), object: value)
        }
    }
}

// MARK: - Usecase

public protocol CAUsecaseProtocol: AnyObject {
    
    associatedtype DTO
    
    var reachabilityManager: CAReachabilityProtocol { get }
    var notificationManager: CANotificationProtocol { get }
    var reportManager: CAReportProtocol { get }
    var storeManager: CAStoreManager { get }
    
    var config: [CAUsecaseOption] { get set }
    
    func input(dto: DTO?) throws -> DTO?
    func output(dto: DTO) throws -> DTO
    func stdErr(error: Error) -> Error
    
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    func dataFetch(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    
}

public extension CAUsecaseProtocol {
    
    var reachabilityManager: CAReachabilityProtocol { ReachabilityManager.shared }
    var notificationManager: CANotificationProtocol { CANotificationManager.shared }
    var reportManager: CAReportProtocol { CAReportManager.shared }
    var storeManager: CAStoreManager { CAStoreManager.shared }
    
    func input(dto: DTO?) throws -> DTO? { dto }
    func output(dto: DTO) throws -> DTO { dto }
    func stdErr(error: Error) -> Error { error }
    
    private func handleReachability(options: [CAUsecaseOption]) throws {
        guard !options.contains(.disableReachability) else {
            return
        }
        guard reachabilityManager.isConnectedToNetwork() else {
            throw CAError.networkIssue
        }
    }
    
    private func sendSnackBarIssue(type: CANotificationManager.AlertType, options: [CAUsecaseOption]) {
        if !options.contains(.disableSnackBar), !options.contains(.disableNotificationCenter) {
//            notificationManager.alert(type: type)
        }
    }
    
    @MainActor
    private func handleError(error: Error, dto: String, options: [CAUsecaseOption]) async -> Error {
        switch error.toCAError {
        case .forbiddenAccess(let request):
            if !options.contains(.disableNotificationCenter) {
                notificationManager.post(id: "forbiddenAccess", value: request)
            }
//        case .badRequest(let data):
//            guard data == nil else {
//                break
//            }
//            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .missingData, .missingDTO, .requestCreate:
            reportManager.pushLocalError(caError: error.toCAError, className: dto)
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .webServiceIssue, .notFound:
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .networkIssue:
            sendSnackBarIssue(type: .networkIssue, options: options)
        case .decodableData(request: let request, error: let error, data: let data):
            Task { await reportManager.sendDecodableStrapi(request: request, error: error, json: data) }
        case .timeOut:
            break // report ?
        default:
            break
        }
        return error
    }
    
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO {
        let taskOptions = self.config + options
        
        do {
            let input = try input(dto: dto)
            try handleReachability(options: taskOptions)
            let data = try await dataFetch(dto: input, options: taskOptions)
            let output = try output(dto: data)
            return output
        } catch {
            let caError = stdErr(error: error)
            throw await handleError(error: caError, dto: String(describing: Self.Type.self), options: taskOptions)
        }
    }
}


// MARK: - Verbatim

struct TestDTO {
    
}

protocol TestUsecaseProtocol {
    func dataTaskAsync(dto: TestDTO?, options: [CAUsecaseOption]) async throws -> TestDTO
 }

extension CAInjectedValues {
    var keyTest: TestUsecaseProtocol {
        get { Self[TestUsecase.self] }
        set { Self[TestUsecase.self] = newValue }
    }
}

extension TestUsecase: CAInjectionKey, CAPreviewProtocol, TestUsecaseProtocol {
    
    var keys: [CAPreviewKey] { Key.allCases.map({ .init(label: $0.label, key: $0.rawValue) }) }
    func inject(key: String?) { TestUsecase.currentValue = key.flatMap({Key(rawValue: $0)}).map({TestUsecase(key: $0)}) ?? self }
    var label: String { "Test" }
}

final class TestUsecase: CAUsecaseProtocol {
    
    static var currentValue: TestUsecaseProtocol = TestUsecase()
    
    private let key: Key
    private let repository: TestRepositoryProtocol
    
    var config: [CAUsecaseOption] = []
    
    init(key: Key? = nil, repo: TestRepositoryProtocol = TestRepository()) {
        self.repository = repo
        self.key = key ?? .prod
        self.config = key.flatMap({[.useTestUIServer(mock: $0.rawValue)]}) ?? []
    }
    
    enum Key: String, CaseIterable {
        
        case prod, luc, jean, pierre
        
        var label: String {
            switch self {
            case .prod: return "Production"
            default: return self.rawValue
            }
        }
    }
        
    func dataFetch(dto: TestDTO?, options: [CAUsecaseOption]) async throws -> TestDTO {
        try await repository.dataTaskAsync(dto: dto ?? .init(), options: options)
    }
}

extension TestUsecase {
    
//    enum Failure: Error {
//
//    }
    
//    func input(dto: TestDTO?) throws -> TestDTO? {
//        dto
//    }
    
//    func output(dto: TestDTO) throws -> TestDTO {
//        dto
//    }
    
//    func stdErr(error: Error) -> Error {
//        error
//    }
}
