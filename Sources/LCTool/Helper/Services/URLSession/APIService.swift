//
//  APIService.swift
//  TestV6
//
//  Created by Free on 31/05/2024.
//

import Foundation

public final class APIService {
    
    public static var shared = APIService()
    private init() {}
    
    // MARK: - Logs
    
    public var logs = [Log]()
    
    public struct Log {
        var date: Date
        var request: URLRequest
        var response: URLResponse?
        var data: Data?
        var error: Error?
    }
    
    // MARK: - Mock
    
    private var mockServer: (host: String?, queryParams: [String: String]?)?
    
    public func setMockServer(path: String?, queryParams: [String: String]) {
        self.mockServer = (path, queryParams)
    }
    
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
    
    // MARK: - Task
    
    public enum Failure: Error {
        case missingURI
    }
    
    private func dataAsync(request: URLRequest) async throws -> (Data, URLResponse) {
        #if DEBUG
        var log = Log(date: Date(), request: request)
        
        defer {
            self.logs.append(log)
        }
        
        do {
            let result = try await URLSession.shared.data(for: swapMockHost(request: request))
            log.data = result.0
            log.response = result.1
            return result
        } catch {
            log.error = error
            throw error
        }
        #else
        return try await URLSession.shared.data(for: swapMockHost(request: request))
        #endif
    }
    
    // MARK: - Fetch
    
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
            return try JSONDecoder().decode(T.self, from: result.0)
        }
        
        if let url = url {
            let result = try await dataAsync(request: URLRequest(url: url))
            return try JSONDecoder().decode(T.self, from: result.0)
        }
        
        if let path = path, let request = URL(string: path).flatMap({URLRequest(url: $0)}) {
            let result = try await dataAsync(request: request)
            return try JSONDecoder().decode(T.self, from: result.0)
        }
        
        throw Failure.missingURI
    }
}
