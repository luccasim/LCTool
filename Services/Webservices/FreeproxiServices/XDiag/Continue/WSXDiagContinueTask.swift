//
//  WSXDiagContinueTask.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation
import Combine

// MARK: - Protocol

protocol WSXDiagContinueTaskProtocol {
    func dataTask(params: WSXDiagContinueParams, completion: @escaping WSXDiagContinueCompletion)
}

// MARK: - TypeAlias

typealias WSXDiagContinueCompletion = (Result<WSXDiagContinueResponse?, Error>) -> Void

// MARK: - Params

struct WSXDiagContinueParams: Codable {
    var httpHeader: [String: String] = [:]
    var clientID: String = ""
    var instanceID: String = ""
}

// MARK: - Protocol

extension CAWebserviceManager: WSXDiagContinueTaskProtocol {
            
    func dataTask(params: WSXDiagContinueParams,
                  completion: @escaping WSXDiagContinueCompletion) {
        
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
        let bodyRequest: WSXDiagContinueBody? = WSXDiagContinueBody(params: .init(instanceID: params.instanceID))
        let json: Data? = bodyRequest.flatMap({try? JSONEncoder().encode($0)})
        body = .json(json)
        
        // URLRequest
        guard let request = URLRequest(path: url, queries: queries, httpMethod: method, header: header, bodyForm: body) else {
            return completion(.failure(CAError.requestCreate))
        }
        // Description
        let description = "XDiag Continue"
        
        self.dataTask(request: request, desc: description, debug: false, completion: completion)
    }
}
