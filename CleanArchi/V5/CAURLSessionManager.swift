//
//  CAURLSessionManager.swift
//  Mon Compte Free
//
//  Created by Free on 10/11/2023.
//

import Foundation

protocol CAURLSessionProtocol {
    func jsonTask<Endpoint: CAEndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.T
    func set(options: [CAUsecaseOption]) async
}

actor CAURLSessionManager: CAURLSessionProtocol {
    
    let session = URLSession.shared
    
    func set(options: [CAUsecaseOption]) async {
    }
    
    
    private func httpStatusCode(httpResponse: URLResponse, request: URLRequest, data: Data? = nil) throws {
        switch (httpResponse as? HTTPURLResponse)?.statusCode {
        case 400:
            throw CAError.badRequest(source: data)
        case 401:
            throw CAError.unAuthorized(data: data)
        case 403, 503:
            throw CAError.forbiddenAccess(request: request, data: data)
        case 404:
            throw CAError.notFound
        case 421:
            throw CAError.tooManyConnections
        case 500:
            throw CAError.webServiceIssue
        case 204:
            throw CAError.noContent
        default:
            break
        }
    }
    
    func download(request: URLRequest?) async throws -> URL {
        
        guard let request = request else {
            throw CAError.requestCreate
        }
        
        var log = CAWebserviceManager.History(request: request)
        log.mime = request.url?.pathExtension
        
        defer {
            NotificationCenter.default.post(name: .init("loggerService"), object: ("legacyWebService", log))
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
    
    func dataTask(request: URLRequest?) async throws -> Data? {
        guard let request = request else {
            throw CAError.requestCreate
        }
                
        let result = try await URLSessionService().fetchData(request: request)
        return result.0
    }
    
    func jsonTask<Endpoint: CAEndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.T {
        guard let request = endpoint.request else {
            throw CAError.requestCreate
        }
        
        let result: Endpoint.T = try await URLSessionService().fetchJSON(request: request)
        return result
    }
}

actor MockOptionActor {
    private var mockID: [String]?
    private var cacheLimit: Double?
    
    func setMockID(_ id: [String]?) async {
        mockID = id
    }
    
    func setCacheLimit(_ limit: Double?) async {
        cacheLimit = limit
    }
    
    func getMockID() async -> [String]? {
        return mockID
    }
    
    func getCacheLimit() async -> Double? {
        return cacheLimit
    }
}
