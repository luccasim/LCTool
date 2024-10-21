//
//  APIService.swift
//  Mon Compte Free
//
//  Created by Free on 31/05/2024.
//

import Network
import SystemConfiguration
import Foundation

public final class URLSessionService {
    
    public init(mockServer: (host: String?, queryParams: [String: String]?)? = nil) {
        self.mockServer = mockServer
    }
        
    // MARK: - Errors
    
    public enum Failure: Error, LocalizedError {
        case missingURI
        case notConnectedToNetwork
        case invalidStatusCode(request: URLRequest, response: URLResponse, data: Data)
        case decodable(url: URL, error: DecodingError, data: Data, description: String)
        
        public var errorDescription: String? {
            switch self {
            case .missingURI:
                return "Can't create URL"
            case .notConnectedToNetwork:
                return "Not connected to network"
            case .invalidStatusCode(request: let request, response: let response, data: _):
                let code = (response as? HTTPURLResponse)?.statusCode
                return "Invalid status code: \(code?.description ?? "xx") for \(request.url?.absoluteString ?? "")"
            case .decodable(url: let url, error: let error, data: _, description: _):
                return "Decodable Error: \(error.localizedDescription) for \(url.absoluteString)"
            }
        }
    }
    
    private func decode<T: Codable>(data: Data, request: URLRequest) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            guard let decodableError = error as? DecodingError, let url = request.url else {
                throw error
            }
            switch decodableError {
            case .valueNotFound(let type, let context):
                let description = "Could not find \(type) in \(context.codingPath)"
                let suggestion = "Try adding a default value to \(type) or use .nullable to ignore missing values."
                throw Failure.decodable(url: url, error: decodableError, data: data, description: description + "\n" + suggestion)
            case .typeMismatch(let type, let context):
                let description = "Expected \(type) but found \(context.debugDescription)"
                let suggestion = "Try adding a default value to \(type) or use .nullable to ignore missing values."
                throw Failure.decodable(url: url, error: decodableError, data: data, description: description + "\n" + suggestion)
            case .keyNotFound(let key, let context):
                let description = "Could not find key \(key) in \(context.codingPath)"
                let suggestion = "Try adding a default value to \(key) or use .nullable to ignore missing values."
                throw Failure.decodable(url: url, error: decodableError, data: data, description: description + "\n" + suggestion)
            case .dataCorrupted(let context):
                let description = "Data could not be decoded"
                let suggestion = "Content may be corrupted. Try using a different decoder. \(context.debugDescription)"
                throw Failure.decodable(url: url, error: decodableError, data: data, description: description + "\n" + suggestion)
            default:
                throw Failure.decodable(url: url, error: decodableError, data: data, description: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Mock
    
    private let mockServer: (host: String?, queryParams: [String: String]?)?
    
    private func swapMockHost(request: URLRequest) -> URLRequest {
        guard let hostMockServer = mockServer?.host, let url = request.url, let host = url.host else {
            return request
        }
        
        let mockPath = url.absoluteString.replacingOccurrences(of: host, with: hostMockServer)
        guard let mockURL = URL(string: mockPath) else {
            return request
        }
        
        var mockRequest = URLRequest(url: mockURL)
        if let mockQueryParams = mockServer?.queryParams {
            mockQueryParams.forEach { (key: String, value: String) in
                mockRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        return mockRequest
    }
    
    // MARK: - Reachability
    
    /// Working for Cellular and WIFI
    private var isConnectedToNetwork: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0,
                                      sin_family: 0,
                                      sin_port: 0,
                                      sin_addr: in_addr(s_addr: 0),
                                      sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        guard let route = defaultRouteReachability, SCNetworkReachabilityGetFlags(route, &flags) else {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    // MARK: - NotificationCenter
    
    private func post(key: String, object: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init(key), object: object)
        }
    }
    
    // MARK: - Task
    
    private func dataAsync(request: URLRequest) async throws -> (Data, URLResponse) {

        var log = [String: Any]()
        log["request"] = request

        defer {
            post(key: "loggerService", object: ("urlSession", log))
        }
        
        do {
            guard isConnectedToNetwork else {
                throw Failure.notConnectedToNetwork
            }
            
            let result = try await URLSession.shared.data(for: swapMockHost(request: request))
            
            guard let statusCode = (result.1 as? HTTPURLResponse)?.statusCode, (200...300).contains(statusCode) else {
                throw Failure.invalidStatusCode(request: request, response: result.1, data: result.0)
            }
            
            log["data"] = result.0
            log["response"] = result.1
            
            return result
        } catch {
            log["error"] = error
            throw error
        }
    }
    
    public func fetchData(request: URLRequest? = nil, url: URL? = nil, path: String? = nil) async throws -> (Data, URLResponse) {
        if let request = request {
            return try await dataAsync(request: request)
        }
        
        if let url = url {
            return try await dataAsync(request: URLRequest(url: url))
        }
        
        if let path = path, let request = URL(string: path).flatMap({URLRequest(url: $0)}) {
            return try await dataAsync(request: request)
        }
        
        throw Failure.missingURI
    }
        
    public func fetchJSON<T: Codable>(request: URLRequest? = nil, url: URL? = nil, path: String? = nil) async throws -> T {

        if let request = request {
            let result = try await dataAsync(request: request)
            return try decode(data: result.0, request: request)
        }
        
        if let url = url {
            let request = URLRequest(url: url)
            let result = try await dataAsync(request: request)
            return try decode(data: result.0, request: request)
        }
        
        if let path = path, let request = URL(string: path).flatMap({URLRequest(url: $0)}) {
            let result = try await dataAsync(request: request)
            return try decode(data: result.0, request: request)
        }
        
        throw Failure.missingURI
    }
    
    public func fetchJSON<Endpoint: URLSessionServiceEndpoint>(withEndpoint: Endpoint) async throws -> Endpoint.Response {
        if let request = withEndpoint.request {
            let result = try await dataAsync(request: request)
            return try decode(data: result.0, request: request)
        }
        throw Failure.missingURI
    }
}

// MARK: - Endpoint

public protocol URLSessionServiceEndpoint: Sendable {
    var request: URLRequest? { get }
    associatedtype Response: Codable, Sendable
}
