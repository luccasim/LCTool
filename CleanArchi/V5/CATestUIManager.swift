//
//  CATestUIManager.swift
//  Mon Compte Free
//
//  Created by Free on 14/11/2023.
//

import Foundation

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
