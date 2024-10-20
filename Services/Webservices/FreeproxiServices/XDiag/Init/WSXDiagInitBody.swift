//
//  WSXDiagInitBody.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation

// MARK: - Codable

struct WSXDiagInitBody: Codable {
    var command = "create_instance"
    var params = Params()
    
    struct Params: Codable {
        var module = "xp"
        var execute = true
    }
}
