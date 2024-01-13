//
//  File.swift
//  
//
//  Created by Luc on 09/01/2024.
//

import Foundation

// MARK: Webservice

protocol CAURLSessionProtocol {
    func jsonTask<Endpoint: EndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.Response
    func set(options: [CAUsecaseOption])
}

final class CAURLSessionManager: CAURLSessionProtocol {
    
    var session = URLSession.shared
//    var expireCache = CACacheManager.shared
    var logManager = LogManager()
    
    var mockID: [String]?
    var cacheLimit: Double?
    
    func set(options: [CAUsecaseOption]) {
        mockID = nil
        cacheLimit = nil
        options.forEach { item in
            switch item {
            case .useCache(let limit):
                cacheLimit = limit
            case .useTestUIServer(let mock):
                mockID = mock.components(separatedBy: ";").reversed()
            default:
                break
            }
        }
    }
    
//    private func httpStatusCode(httpResponse: URLResponse, request: URLRequest, data: Data? = nil) throws {
//        switch (httpResponse as? HTTPURLResponse)?.statusCode {
//        case 400:
//            guard let data = data else {
//                throw CAError.badRequest()
//            }
//            do {
//                let json = try JSONDecoder().decode(APIError.self, from: data)
//                throw CAError.badRequest(data: json)
//            } catch {
//                throw CAError.decodableData(request: request, error: error, data: data)
//            }
//        case 401:
//            throw CAError.authentication
//        case 403:
//            throw CAError.forbiddenAccess(request: request)
//        case 404:
//            throw CAError.notFound
//        case 500:
//            throw CAError.webServiceIssue
//        default:
//            break
//        }
//    }
    
    func downloadTask(request: URLRequest?) async throws -> URL {
        
        guard let request = request?.mapToTestUIServer(id: mockID?.popLast()) else {
            throw CAError.requestCreate
        }
        
        var log = logManager.log(request: request)
        
        defer {
            self.logManager.addHistories(log: log)
        }
        
        do {
            let result = try await self.session.download(for: request)
            log.httpResponse = result.1 as? HTTPURLResponse
            return result.0
        } catch {
            log.httpError = error
            throw error
        }
    }
    
    func dataTask(request: URLRequest?) async throws -> Data {
        
        guard let request = request?.mapToTestUIServer(id: mockID?.popLast()) else {
            throw CAError.requestCreate
        }
        
        var log = logManager.log(request: request)

        defer {
            self.logManager.addHistories(log: log)
        }
        
        do {
            let result = try await self.session.data(for: request)
            log.httpResponse = result.1 as? HTTPURLResponse
            return result.0
        } catch {
            log.httpError = error
            throw error
        }
    }
    
    func jsonTask<Endpoint: EndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.Response {
        
        guard let request = endpoint.request?.mapToTestUIServer(id: mockID?.popLast()) else {
            throw CAError.requestCreate
        }
        
//        if cacheLimit != nil, let key = request.caDescription, let data = self.expireCache[key] as? Data,
//            let json = try? JSONDecoder().decode(Endpoint.T.self, from: data) {
//                return json
//        }
        
//        var log = CAWebserviceManager.History(request: request)
//        
//        defer {
//            self.logManager.addHistories(log: log)
//        }
        
        do {
            let result = try await session.data(for: request)
//            log.httpResponse = result.1 as? HTTPURLResponse
//            log.httpData = result.0
            
//            try httpStatusCode(httpResponse: result.1, request: request)
            
            let json = try JSONDecoder().decode(Endpoint.Response.self, from: result.0)
            
//            if let cacheTime = cacheLimit, let key = request.caDescription {
//                self.expireCache[key, cacheTime] = result.0
//            }
            
            return json
        } catch {
//            log.httpError = error
            throw error
        }
    }
}

// MARK: - Mock

final class CATestUIManager {
    
    static let shared = CATestUIManager()
    
    var serverHost: String?
    var useMockServerPreferences: Bool {
        get {
            UserDefaults.standard.bool(forKey: "CAuseMockServerPreferences")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CAuseMockServerPreferences")
        }
    }
    
    func register(host: String) {
        self.serverHost = host
    }
    
    func replaceHost(request: URLRequest, id: String?) -> URLRequest {
        
        guard let url = request.url, let currentHost = url.host, let serverHost = serverHost, let id = id else {
            return request
        }
        
        var mockHeader = request.allHTTPHeaderFields
        mockHeader?["x-mock-response-name"] = id
        
        var newRequest = request
        newRequest.url = URL(string: url.absoluteString.replacingOccurrences(of: currentHost, with: serverHost))
        newRequest.allHTTPHeaderFields = mockHeader
        newRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        return newRequest
    }
}

extension URLRequest {
    func mapToTestUIServer(id: String? = nil) -> URLRequest? {
        CATestUIManager.shared.replaceHost(request: self, id: id)
    }
}

// MARK: - Logs

public class LogManager {
    
    var histories: [History] = []
    
    func log(request: URLRequest) -> History {
        .init(request: request)
    }
    
    struct History {
        var request: URLRequest
        var httpResponse: HTTPURLResponse?
        var httpData: Data?
        var httpError: Error?
        var id = UUID()
        
        var description: String?
        
        var statusCode: Int {
            guard let code = httpResponse?.statusCode else {
                return 404
            }
            return code
        }
        
//        var serviceDescription: String {
//            request.caDescription ?? description ?? request.url?.absoluteString
//                .replacingOccurrences(of: "https://", with: "") ?? ""
//        }
        
        var responseDateStr: String {
            httpResponse?.allHeaderFields["Date"] as? String ?? ""
        }
        
        var jsonData: String? {
//            httpData?.prettyJSONString as? String
            ""
        }
        
        var httpErrorDescription: String? {
            httpError?.localizedDescription
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
            return fields.map({$0.value}).reduce("\n") { (result, element) in
                result + "\t" + element + "\n"
            }
        }
        
        var requestHttpBody: String? {
            guard let json = request.httpBody?.description else {
                return nil
            }
            return "\n\(json)"
        }
        
        var responseData: String {
            guard let data = httpData else {
                return ""
            }
            return "\nDATA:\n\(data.description)"
        }
        
        var responseError: String {
            guard let error = httpError else {
                return ""
            }
            return "\nERROR:\n\(error.localizedDescription)"
        }
        
        var requestStr: String {
            "\nHEADER:\n\n" +
            "- URL: \(request)\n" +
            "- HTTP HEADER: \n[\(requestAllHTTPHeaderFields)]\n" +
            "- HTTP METHOD: \(request.httpMethod ?? "")\n" +
            "- HTTP BODY: \(requestHttpBody ?? "")"
        }
        
        func printDebug(debug: Bool) {
            guard debug else { return }
            print("\n-------------------------------------------------------")
            print(requestStr)
            if let response = httpResponse, let date = response.allHeaderFields["Date"] {
                print("\nRESPONSE:\n\n- STATUS: \(response.statusCode)\n- DATE: \(date)")
            }
            if httpData != nil {
                print(responseData)
            }
            if let error = httpError {
                print(error.localizedDescription)
            }
        }
    }
    
    func clearHistories() {
        histories = []
    }
    
    func addHistories(log: History) {
//        log.printDebug(debug: self.showDebug)
//        DispatchQueue.main.async {
            self.histories.append(log)
//        }
    }
    
}

// MARK: - Errors

enum CAError: Error {
    
    /// Bad Request sent to the API
    case badRequest
    
    /// User has network issue like airplay mode
    case networkIssue
    
    /// Webservice return an error, or some responses can't be read
    case webServiceIssue
    
    /// Can't retrieve a stored data
    case missingData
    
    /// Can't retrieve a DTO
    case missingDTO
    
    /// Access token is revoked,  user should be disconnect
    case forbiddenAccess(request: URLRequest?)
    
    /// User authentication failed
    case authentication
    
    /// Fail to create a request
    case requestCreate
    
    /// Report a usecase error
    case usecase(error: Error)
    
    /// Report data when Codable Fail
    case decodableData(request: URLRequest, error: Error, data: Data)
    
    /// Data not found
    case notFound
    
    /// TimeOut
    case timeOut
}

// MARK: - Options

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

// MARK: - CAStore

protocol CAStoreProtocol: AnyObject {
    
    func save(value: Any?, forKey: String)
    func retrieve(forKey: String) -> Any?
    
//    func saveCache(value: Any, forKey: String, forTime: TimeInterval?)
//    func retrieveCache(forKey: String) -> Any?
//    func removeCache(forKey: String)
//    
//    func saveCodable<T: Codable>(value: T, forKey: String)
//    func retrieveCodable<T: Codable>(forKey: String) -> T?
//    func removeCodable(forKey: String)
//    
//    func saveAsEncryption(value: String?, forKey: String)
//    func retrieveAsEncryption(forKey: String) -> String?
//    func removeAsEncryption(forKey: String)
}

// MARK: - Store

final class CAStoreManager {
    
    static let shared = CAStoreManager()
    private init() {}
    
//    private let writeFileManager = WriteFileManager()
//    private let keychainManager = KeychainManager()
//    private let cacheManager = ExpireCacheManager()
}

// MARK: - Extension

extension CAStoreManager: CAStoreProtocol {
    
    // MARK: - UserDefault
    
    func save(value: Any?, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    func retrieve(forKey: String) -> Any? {
        UserDefaults.standard.object(forKey: forKey)
    }
    
//    // MARK: - Cache
//    
//    func saveCache(value: Any, forKey: String, forTime: TimeInterval?) {
//        cacheManager.set(id: forKey, value: value, limit: forTime)
//    }
//    
//    func retrieveCache(forKey: String) -> Any? {
//        cacheManager.get(id: forKey)
//    }
//    
//    func removeCache(forKey: String) {
//        cacheManager.set(id: forKey, value: nil)
//    }
//    
//    // MARK: - Codable
//    
//    func saveCodable<T: Codable>(value: T, forKey: String) {
//        writeFileManager.write(codableFileName: forKey, codableData: value)
//    }
//    
//    func retrieveCodable<T: Codable>(forKey: String) -> T? {
//        writeFileManager.read(codableFileName: forKey)
//    }
//    
//    func removeCodable(forKey: String) {
//        writeFileManager.delete(fileName: forKey)
//    }
//    
//    // MARK: - Encryption
//    
//    func saveAsEncryption(value: String?, forKey: String) {
//        keychainManager.set(value: value, forKey: forKey)
//    }
//    
//    func retrieveAsEncryption(forKey: String) -> String? {
//        keychainManager.get(forKey: forKey)
//    }
//    
//    func removeAsEncryption(forKey: String) {
//        keychainManager.delete(forKey: forKey)
//    }
}
