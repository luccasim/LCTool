//
//  Errors+CleanArchi.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

import Foundation

// MARK: - Error

protocol CAErrorHandlerServiceProtocol: Sendable {
    func checkReachability(options: [CAUsecaseOption]) throws
    func checkError(dto: String, error: Error, options: [CAUsecaseOption]) async -> Error
}

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

extension Data {
    var fbxAPIError: APIError? {
        return try? JSONDecoder().decode(APIError.self, from: self)
    }
}

enum CAError: Error {
    
    /// Bad Request sent to the API
    case badRequest(source: Data? = nil)
    
    /// User has network issue like airplay mode
    case networkIssue
    
    /// Webservice return an error, or some responses can't be read
    case webServiceIssue
    
    /// Can't retrieve a stored data
    case missingData
    
    /// Can't retrieve a DTO
    case missingDTO
    
    /// Access token is revoked,  user should be disconnect
    case forbiddenAccess(request: URLRequest?, data: Data?)
    
    /// User unAuthorized failed
    case unAuthorized(data: Data?)
    
    /// Fail to create a request
    case requestCreate
    
    /// Report a usecase error
    case usecase(error: Error)
    
    /// Report data when Codable Fail
    case decodableData(request: URLRequest, error: Error, data: Data)
    
    /// Data not found
    case notFound
    
    /// Timeout > 20 secondes
    case timeOut
    
    /// Success but no content
    case noContent
    
    /// Too many connections with IP
    case tooManyConnections
    
    /// Report an message
    case report(title: String, message: String)
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

extension CAError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            "Bad request"
        case .networkIssue:
            "Not reachable"
        case .webServiceIssue:
            "Webservice Issue"
        case .missingData:
            "Missing Data"
        case .missingDTO:
            "Missing DTO"
        case .forbiddenAccess(let request, data: _):
            "Forbidden Access for \(request?.url?.path ?? "")"
        case .unAuthorized:
            "Authentication fail"
        case .requestCreate:
            "URLRequest fail"
        case .usecase(let error):
            "Usecase Error: \(error.localizedDescription)"
        case .decodableData(_, let error, _):
            "Decodable Error: \(error.localizedDescription)"
        case .notFound:
            "Not Found"
        case .timeOut:
            "Time out"
        case .noContent:
            "No Content"
        case .tooManyConnections:
            "Too many connections with IP"
        case .report(title: let title, message: let message):
            "Report:`\(title)`\n\(message)"
        }
    }
    
    func handleWithToast() {
        switch self {
        case .webServiceIssue:
            NotificationCenter.show(type: .webserviceIssue)
        case .networkIssue:
            NotificationCenter.show(type: .networkIssue)
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
