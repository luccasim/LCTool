//
//  FreeErrorHandlerService.swift
//  Mon Compte Free
//
//  Created by Free on 08/07/2024.
//

import Foundation

final class FreeErrorHandler: ObservableObject, CAErrorHandlerServiceProtocol {
    
    static let shared = FreeErrorHandler()

    private var notificationManager: CANotificationProtocol { CANotificationManager.shared }
    private var reportManager: CAReportProtocol { CAReportManager.shared }
    
    private func sendSnackBarIssue(type: CANotificationManager.AlertType, options: [CAUsecaseOption]) {
        if !options.contains(.disableSnackBar), !options.contains(.disableNotificationCenter) {
            notificationManager.alert(type: type)
        }
    }
    
    func checkReachability(options: [CAUsecaseOption]) throws {
        guard !options.contains(.disableReachability) else {
            return
        }
        guard ReachabilityManager().isConnectedToNetwork() else {
            throw CAError.networkIssue
        }
    }
    
    func handle(usecase: AnyObject, error: Error, options: [CAUsecaseOption] = []) -> Error {
        self.checkError(dto: String(describing: usecase), error: error, options: options)
    }
    
    func checkError(dto: String, error: Error, options: [CAUsecaseOption]) -> Error {
        
        guard !options.contains(.disableErrorHandler) else {
            return error
        }
        
        switch error.toCAError {
        case .forbiddenAccess(let request, data: _) where !options.contains(.disableNotificationCenter):
            NotificationCenter.post(id: "forbiddenAccess", value: request)
        case .badRequest(let data) where data == nil:
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .missingData, .missingDTO, .requestCreate:
            reportManager.pushLocalError(caError: error.toCAError, className: dto)
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .webServiceIssue, .notFound:
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .networkIssue:
            sendSnackBarIssue(type: .networkIssue, options: options)
        case .decodableData(request: let request, error: let error, data: let data):
            Task { await reportManager.reportDecodableStrapi(request: request, error: error, json: data) }
        case .timeOut:
            break
        default:
            break
        }
        
        return error
    }
}
