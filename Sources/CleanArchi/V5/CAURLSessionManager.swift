//
//  CAURLSessionManager.swift
//  Mon Compte Free
//
//  Created by Free on 10/11/2023.
//

import Foundation

protocol CAURLSessionProtocol {
    func jsonTask<Endpoint: CAEndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.T
    func set(options: [CAUsecaseOption])
}

final class CAURLSessionManager: CAURLSessionProtocol {
    
    var session = URLSession.shared
    var expireCache = CACacheManager.shared
    var logManager = CAWebserviceManager.shared // keep this for logs v4 & v5
    
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
    
    private func httpStatusCode(httpResponse: URLResponse, request: URLRequest, data: Data? = nil) throws {
        switch (httpResponse as? HTTPURLResponse)?.statusCode {
        case 400:
            guard let data = data else {
                throw CAError.badRequest()
            }
            do {
                let json = try JSONDecoder().decode(APIError.self, from: data)
                throw CAError.badRequest(data: json)
            } catch {
                throw CAError.decodableData(request: request, error: error, data: data)
            }
        case 401:
            throw CAError.authentication
        case 403:
            throw CAError.forbiddenAccess(request: request)
        case 404:
            throw CAError.notFound
        case 500:
            throw CAError.webServiceIssue
        default:
            break
        }
    }
    
    func downloadTask(request: URLRequest?) async throws -> URL {
        
        guard let request = request?.mapToTestUIServer(id: mockID?.popLast()) else {
            throw CAError.requestCreate
        }
        
        var log = CAWebserviceManager.History(request: request)
        
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
        
        var log = CAWebserviceManager.History(request: request)
        
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
    
    func jsonTask<Endpoint: CAEndpointProtocol>(endpoint: Endpoint) async throws -> Endpoint.T {
        
        guard let request = endpoint.request?.mapToTestUIServer(id: mockID?.popLast()) else {
            throw CAError.requestCreate
        }
        
        if cacheLimit != nil, let key = request.caDescription, let data = self.expireCache[key] as? Data,
            let json = try? JSONDecoder().decode(Endpoint.T.self, from: data) {
                return json
        }
        
        var log = CAWebserviceManager.History(request: request)
        
        defer {
            self.logManager.addHistories(log: log)
        }
        
        do {
            let result = try await session.data(for: request)
            log.httpResponse = result.1 as? HTTPURLResponse
            log.httpData = result.0
            
            try httpStatusCode(httpResponse: result.1, request: request)
            
            let json = try JSONDecoder().decode(Endpoint.T.self, from: result.0)
            
            if let cacheTime = cacheLimit, let key = request.caDescription {
                self.expireCache[key, cacheTime] = result.0
            }
            
            return json
        } catch {
            log.httpError = error
            throw error
        }
    }
}
