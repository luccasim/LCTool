//
//  Errors+CleanArchi.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

import Foundation

// MARK: - Error

struct APIError: Codable {
    var errorDescription: String?
    var errorDisplay: Int?
    var error: String?
    
    enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description"
        case errorDisplay = "error_display"
        case error
    }
}

enum CAError: Error {
    
    /// Bad Request sent to the API
    case badRequest(data: APIError? = nil)
    
    /// User has network issue like airplay mode
    case networkIssue
    
    /// Webservice return an error, or some responses can't be read
    case webServiceIssue
    
    /// Can't retrieve a stored data
    case missingData
    
    /// Can't retrieve a DTO
    case missingDTO
    
    /// Access token is revoked,  user should be disconnect
    case forbiddenAccess(request: URLRequest?)
    
    /// User authentication failed
    case authentication
    
    /// Fail to create a request
    case requestCreate
    
    /// Report a usecase error
    case usecase(error: Error)
    
    /// Report data when Codable Fail
    case decodableData(request: URLRequest, error: Error, data: Data)
    
    /// Data not found
    case notFound
    
    case timeOut
}

extension Error {
    
    var toCAError: CAError {
        if let domainFailure = self as? CAError {
            return domainFailure
        }
        
        if (self as? URLError)?.code == .timedOut {
            return CAError.timeOut
        }
        
        switch self {
        case is DecodingError, is URLError:
            return CAError.webServiceIssue
        default:
            return CAError.usecase(error: self)
        }
    }
}

extension CAError {
    
    func handleWithToast() {
        switch self {
//        case .webServiceIssue:
//            NotificationCenter.show(type: .webserviceIssue)
//        case .networkIssue:
//            NotificationCenter.show(type: .networkIssue)
        default:
            break
        }
    }
    
    var usecaseError: Error? {
        switch self {
        case .usecase(error: let error):
            return error
        default:
            return nil
        }
    }
}
