//
//  WebService+CleanArchi.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

// swiftlint:disable file_length
import Foundation

// MARK: - Protocol

protocol CAWebserviceProtocol {
    func downloadTask(request: URLRequest?, completion: @escaping (Result<URL, Error>) -> Void)
    func downloadTask(requests: [URLRequest],
                      completion: @escaping (Result<(URLRequest, URL), Error>) -> Void,
                      finished: @escaping ([URLRequest]) -> Void)
    func dataTask(request: URLRequest?, completion: @escaping (Result<Data, Error>) -> Void)
    func dataTask(request: URLRequest?) async throws -> Data
    func jsonTask(endpoint: CAWebserviceManager.EndpointExample,
                  completion: @escaping (Result<CAWebserviceManager.EmptyJSON, Error>) -> Void)
}

// MARK: - Service

final class CAWebserviceManager: ObservableObject {
    
    // MARK: - Properties
    
    @Published var histories = [History]()
    
    let session: URLSession
    static let shared = CAWebserviceManager()
    var debug = false
    var expireCache = ExpireCacheManager()
    
    var useCache: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isPreloadData")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isPreloadData")
            if !newValue {
                self.expireCache.clear()
            }
        }
    }
    
    private var showDebug: Bool {
        ProcessInfo.processInfo.arguments.contains("-verbose") ? true : debug
    }
    
    var host: String? {
        get {
            UserDefaults.standard.string(forKey: "caMapHostURL")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "caMapHostURL")
        }
    }
    
    var reportPath: String?
    
    // MARK: - Init
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
        self.session.sessionDescription = "Main Session"
    }
    
    private func httpStatusCode(httpResponse: HTTPURLResponse, request: URLRequest, data: Data? = nil) throws {
        switch httpResponse.statusCode {
        case 400:
            throw CAError.badRequest(source: data)
        case 401:
            throw CAError.unAuthorized(data: data)
        case 403, 503:
            throw CAError.forbiddenAccess(request: request, data: data)
        case 404:
            throw CAError.notFound
        case 500:
            throw CAError.webServiceIssue
        default:
            break
        }
    }
    
    struct EmptyJSON: Codable {}
    
    // MARK: - Template Example
    
    struct EndpointExample: Codable {}
    
    // Template Example
    func jsonTask(endpoint: EndpointExample, completion: @escaping (Result<EmptyJSON, Error>) -> Void) {
        fatalError("Don't use EmptyJSON as parameter")
    }
}

extension CAWebserviceManager {
    
    // MARK: - History
    
    struct History {
        var request: URLRequest
        var httpResponse: HTTPURLResponse?
        var httpData: Data?
        var httpError: Error?
        var id = UUID()
        var mime: String?
        var env = UserDefaults.standard.string(forKey: "appEnviroment")
        
        var description: String?
        
        var statusCode: Int {
            guard let code = httpResponse?.statusCode else {
                return 404
            }
            return code
        }
        
        var serviceDescription: String {
            request.caDescription ?? description ?? request.url?.absoluteString
                .replacingOccurrences(of: "https://", with: "") ?? ""
        }
        
        var responseDateStr: String {
            httpResponse?.allHeaderFields["Date"] as? String ?? ""
        }
        
        var jsonData: String? {
            httpData?.prettyJSONString as? String
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
            guard let json = request.httpBody?.prettyJSONString else {
                return nil
            }
            return "\n\(json)"
        }
        
        var responseData: String {
            guard let data = httpData else {
                return ""
            }
            return "\nDATA:\n\(data.prettyJSONString)"
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
        #if !PROD
        log.printDebug(debug: self.showDebug)
        DispatchQueue.main.async {
            self.histories.append(log)
        }
        #endif
    }
}

extension CAWebserviceManager: CAWebserviceProtocol {
    
    // MARK: - Download Task
    
    /// Download the file on tmp URL, conform to downloadTask
    /// you must move this file or open it for reading before your completion handler returns.
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The response handler
    func downloadTask(request: URLRequest?, completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard let request = request else {
            return completion(.failure(CAError.missingData))
        }
        
        var log = History(request: request, description: request.caDescription)
        
        session.downloadTask(with: request) { url, response, error in
            
            defer {
                #if !PROD
                log.printDebug(debug: self.showDebug)
                NotificationCenter.default.post(name: .init("loggerService"), object: ("legacyWebService", log))
                #endif
            }
            
            if let error = error {
                log.httpError = error
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                do {
                    log.httpResponse = response
                    try self.httpStatusCode(httpResponse: response, request: request)
                } catch {
                    return completion(.failure(error))
                }
            }
            
            if let url = url {
                completion(.success(url))
            }
        }
        .resume()
    }
    
    /// Download a list of requests, like download task you must handle tmp URL
    /// Failed request is return on the finish completion
    /// - Parameters:
    ///   - requests: List of requests
    ///   - completion: The Request completion
    ///   - finished: The Task completion, return a list of failed request
    func downloadTask(requests: [URLRequest],
                      completion: @escaping (Result<(URLRequest, URL), Error>) -> Void,
                      finished: @escaping ([URLRequest]) -> Void) {
        
        let group = DispatchGroup()
        var failedRequests = [URLRequest]()

        for request in requests {
            group.enter()
            self.downloadTask(request: request) { result in
                switch result {
                case .success(let success):
                    completion(.success((request, success)))
                case .failure(let failure):
                    failedRequests.append(request)
                    completion(.failure(failure))
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            finished(failedRequests)
        }
    }
    
    // MARK: - DataTask
    
    /// The classic URLSessionDataTask
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The completion
    func dataTask(request: URLRequest?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let request = request?.mapHost(host) else {
            return completion(.failure(CAError.requestCreate))
        }
        
        var log = History(request: request, description: request.caDescription)
        
        session.dataTask(with: request) { data, response, error in
            
            defer {
                #if !PROD
                log.printDebug(debug: self.showDebug)
                NotificationCenter.default.post(name: .init("loggerService"), object: ("legacyWebService", log))
                #endif
            }
            
            // Handle session timeout
            if (error as? URLError)?.code == .timedOut {
                completion(.failure(CAError.networkIssue))
            }
            
            if let error = error {
                log.httpError = error
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                do {
                    log.httpResponse = response
                    try self.httpStatusCode(httpResponse: response, request: request, data: data)
                } catch {
                    return completion(.failure(error))
                }
            }
            
            if let data = data {
                log.httpData = data
                return completion(.success(data))
            }
        }
        .resume()
    }
    
    /// A Tester !
    func dataTask(request: URLRequest?) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            self.dataTask(request: request) { result in
                switch result {
                case .success(let data):
                    continuation.resume(with: .success(data))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - JSON DataTask
    
    func jsonTask<T: Codable>(request: URLRequest?, cacheTime: Double? = nil, completion: @escaping (Result<T?, Error>) -> Void) {
        
        guard let request = request?.mapHost(host) else {
            return completion(.failure(CAError.requestCreate))
        }
        
        if cacheTime != nil, self.useCache,
            let key = request.caDescription,
            let data = self.expireCache.get(id: key) as? Data,
            let json = try? JSONDecoder().decode(T.self, from: data) {
                return completion(.success(json))
        }
                
        self.dataTask(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    if data.isEmpty {
                        return completion(.success(.none))
                    }
                    let json = try JSONDecoder().decode(T.self, from: data)
                    if let cacheTime = cacheTime, let key = request.caDescription, self.useCache {
                        self.expireCache.set(id: key, value: data, limit: cacheTime)
                    }
                    return completion(.success(json))
                } catch {
                    return completion(.failure(CAError.decodableData(request: request, error: error, data: data)))
                }
            case .failure(let failure):
                return completion(.failure(failure))
            }
        }
    }
    
    // MARK: - Legacy
    
    /// Legacy dataTask used on CleanArch < 4.1
    func dataTask<T: Codable>(request: URLRequest,
                              desc: String? = nil,
                              debug: Bool,
                              completion: @escaping (Result<T?, Error>) -> Void) {

        var log = History(request: request, description: desc)

        session.dataTask(with: request) { data, response, error in
            
            defer {
                #if !PROD
                log.printDebug(debug: self.showDebug)
                NotificationCenter.default.post(name: .init("loggerService"), object: ("legacyWebService", log))
                #endif
            }
            
            if let error = error {
                log.httpError = error
                return completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                do {
                    log.httpResponse = response
                    try self.httpStatusCode(httpResponse: response, request: request, data: data)
                } catch {
                    return completion(.failure(error))
                }
            }
            
            if let data = data {
                do {
                    log.httpData = data
                    if data.isEmpty {
                        return completion(.success(.none))
                    }
                    let json = try JSONDecoder().decode(T.self, from: data)
                    return completion(.success(json))
                } catch {
                    return completion(.failure(CAError.decodableData(request: request, error: error, data: data)))
                }
            }
        }
        .resume()
    }
}
