//
//  WSXDiagInitResponse.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation

// MARK: - Codable

struct WSXDiagInitResponse: Codable {
    let instanceID: String?
    let workerID: Int?

    enum CodingKeys: String, CodingKey {
        case instanceID = "instance_id"
        case workerID = "worker_id"
    }
}
