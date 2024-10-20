//
//  WSXDiagInitTask.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation
import Combine

// MARK: - Protocol

protocol WSXDiagInitTaskProtocol {
    func dataTask(params: WSXDiagInitParams, completion: @escaping WSXDiagInitCompletion)
}

// MARK: - TypeAlias

typealias WSXDiagInitCompletion = (Result<WSXDiagInitResponse?, Error>) -> Void

// MARK: - Params

struct WSXDiagInitParams: Codable {
    var httpHeader: [String: String] = [:]
    var clientID: String = ""
}

// MARK: - Protocol

extension CAWebserviceManager: WSXDiagInitTaskProtocol {
            
    func dataTask(params: WSXDiagInitParams,
                  completion: @escaping WSXDiagInitCompletion) {
        
        // Header
        let header: [String: String] = params.httpHeader

        // HttpMethod
        let method: URLRequest.HTTPMethod = .post

        // Queries
        let queries: [String: String] = ["id": params.clientID]
        
        // Endpoint
        let url = "https://webdiag.free.fr/xdiag/execute_command_node"
        
        // Body
        var body: URLRequest.BodyForm?
        
        // Json
        let bodyRequest: WSXDiagInitBody? = WSXDiagInitBody()
        let json: Data? = bodyRequest.flatMap({try? JSONEncoder().encode($0)})
        body = .json(json)
        
        // URLRequest
        guard let request = URLRequest(path: url, queries: queries, httpMethod: method, header: header, bodyForm: body) else {
            return completion(.failure(CAError.requestCreate))
        }
        
        // Description
        let description = "XDiag Init"
        
        self.dataTask(request: request, desc: description, debug: false, completion: completion)
    }
}
