//
//  WSXDiagContinueBody.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation

// MARK: - Codable

struct WSXDiagContinueBody: Codable {
    var command = "execute_instance"
    var params: Params
    
    struct Params: Codable {
        var module = "xp"
        var instanceID: String
        var payload = PayLoad()
        
        enum CodingKeys: String, CodingKey {
            case module
            case instanceID = "instance_id"
            case payload
        }
    }
    
    struct PayLoad: Codable {
        var payLoadContinue = 1
        
        enum CodingKeys: String, CodingKey {
            case payLoadContinue = "continue"
        }
    }
}
