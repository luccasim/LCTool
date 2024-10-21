//
//  Logger.swift
//  Mon Compte Free
//
//  Created by Free on 15/09/2024.
//

import Foundation
import Combine

final class LoggerService: ObservableObject {
    
    @Published var urlSessionLogs = [NetworkLog]()
    @Published var errorLogs = [ErrorsLog]()
    @Published var analyticsLogs = [AnalyticsLog]()

    private var cancellables = Set<AnyCancellable>()
    
    private func consoleLog(_ str: String) {
        if ProcessInfo.processInfo.arguments.contains("-debug") {
            print(str)
        }
    }
    
    init() {
        #if !PROD
        NotificationCenter.default.publisher(for: .init("loggerService"))
            .compactMap { notification in
                notification.object as? (String, Any)
            }
            .buffer(size: 200, prefetch: .byRequest, whenFull: .dropOldest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key, log in
                self?.processLog(key: key, log: log)
            }
            .store(in: &cancellables)
        #endif
    }
    
    private func processLog(key: String, log: Any) {
        switch key {
        case "urlSession":
            if let log = log as? [String: Any], let request = log["request"] as? URLRequest {
                let webLog = NetworkLog(request: request,
                                        httpResponse: log["response"] as? HTTPURLResponse,
                                        httpData: log["data"] as? Data,
                                        httpError: log["error"] as? Error,
                                        env: UserDefaults.standard.string(forKey: "appEnviroment"),
                                        serviceLabel: request.allHTTPHeaderFields?["ServiceLabel"])
                urlSessionLogs.append(webLog)
                consoleLog(webLog.description)
            }
        case "errorHandler":
            if let log = log as? [String: Any], let caller = log["caller"] as? String, let error = log["error"] as? Error {
                let errorLog = ErrorsLog(caller: caller, error: error, businessError: log["businessError"] as? Error)
                errorLogs.append(errorLog)
                consoleLog(errorLog.description)
            }
        case "analytics":
            if let log = log as? [String: Any], let event = log["event"] as? String, let action = log["action"] as? String {
                let analyticsLog = AnalyticsLog(event: event, action: action, date: Date())
                analyticsLogs.append(analyticsLog)
                consoleLog(analyticsLog.description)
            }
        default:
            break
        }
    }
    
    func postLog(key: String, log: Any) {
        NotificationCenter.default.post(name: .init("loggerService"), object: (key, log))
    }
    
    // MARK: - Network
    
    struct NetworkLog: CustomStringConvertible {
        
        var request: URLRequest
        var httpResponse: HTTPURLResponse?
        var httpData: Data?
        var httpError: Error?
        var id = UUID()
        var mime: String?
        var env: String?
        var serviceLabel: String?
        
        var statusCode: Int {
            httpResponse?.statusCode ?? 0
        }
        
        var serviceDescription: String {
            serviceLabel ?? request.url?.absoluteString.replacingOccurrences(of: "https://", with: "") ?? ""
        }
        
        var responseDateStr: String {
            httpResponse?.allHeaderFields["Date"] as? String ?? ""
        }
        
        var jsonData: String? {
            httpData?.prettyJSONString as? String
        }
        
        var errorData: String? {
            switch httpError as? URLSessionService.Failure {
            case .invalidStatusCode(request: _, response: _, data: let data):
                return data.prettyJSON
            default:
                return nil
            }
        }
        
        var httpErrorDescription: String? {
            httpError?.localizedDescription
        }
        
        var requestHttpBody: String? {
            request.httpBody?.prettyJSON.flatMap({"\n\($0)"})
        }
        
        var responseData: String {
            httpData.flatMap({"\nDATA:\n\($0.prettyJSONString)"}) ?? ""
        }
        
        var responseError: String {
            httpError.flatMap({"\nERROR:\n\($0.localizedDescription)"}) ?? ""
        }
        
        var header: String? {
            guard let header = request.allHTTPHeaderFields, !header.isEmpty else { return nil }
            let result = header.reduce("[\n") { partialResult, dict in
                "\(partialResult) - \(dict.key): \(dict.value)\n"
            }
            return "\n" + result + "]"
        }
                
        private var requestAllHTTPHeaderFields: String {
            guard let fields = request.allHTTPHeaderFields, !fields.isEmpty else {
                return ""
            }
            return fields.reduce("\n") { (result, element) in
                result + "\t" + element.key + ": " + element.value + "\n"
            }
        }
        
        var requestStr: String {
            "\nHEADER:\n\n" +
            "- URL: \(request)\n" +
            "- HTTP HEADER: \n[\(requestAllHTTPHeaderFields)]\n" +
            "- HTTP METHOD: \(request.httpMethod ?? "")\n" +
            "- HTTP BODY: \(requestHttpBody ?? "")"
        }
        
        var description: String {
            "-----------------------------------------------\n" +
            "Network: - \(serviceLabel ?? "")\n" +
            "\(requestStr)\n" +
            "RESPONSE:\n\n" +
            "- STATUS: \(statusCode)\n" +
            "- DATE: \(responseDateStr)\n" +
            "\(responseData)" +
            "\(responseError)\n" +
            "-----------------------------------------------\n"
        }
    }
    
    // MARK: - Errors
    
    struct ErrorsLog: CustomStringConvertible {
        var caller: String
        var error: Error
        var businessError: Error?
        var date = Date()
        
        var description: String {
            "-----------------------------------------------\n" +
            "Error: - \(caller)\n" +
            "Service Error: - \(error.localizedDescription)\n" +
            "Business Error: - \(businessError?.localizedDescription ?? "No business error")\n" +
            "-----------------------------------------------\n"
        }
    }
    
    // MARK: - Analytics
    
    struct AnalyticsLog: CustomStringConvertible {
        var event: String
        var action: String
        var date = Date()
        
        var description: String {
            "-----------------------------------------------\n" +
            "Analytics: - \(event + action)\n" +
            "-----------------------------------------------\n"
        }
    }
}
