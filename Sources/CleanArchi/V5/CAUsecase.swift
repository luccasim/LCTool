//
//  CAUsecase.swift
//  Mon Compte Free
//
//  Created by Free on 03/11/2023.
//

import Foundation

protocol CAUsecaseProtocol: AnyObject {
    
    associatedtype DTO
    
    var reachabilityManager: CAReachabilityProtocol { get }
    var notificationManager: CANotificationProtocol { get }
    var reportManager: CAReportProtocol { get }
    var storeManager: CAStoreManager { get }
    
    var config: [CAUsecaseOption] { get set }
    
    func input(dto: DTO?) throws -> DTO?
    func output(dto: DTO) throws -> DTO
    func stdErr(error: Error) -> Error
    
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    func dataFetch(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    
}

extension CAUsecaseProtocol {
    
    var reachabilityManager: CAReachabilityProtocol { ReachabilityManager.shared }
    var notificationManager: CANotificationProtocol { CANotificationManager.shared }
    var reportManager: CAReportProtocol { CAReportManager.shared }
    var storeManager: CAStoreManager { CAStoreManager.shared }
    
    func input(dto: DTO?) throws -> DTO? { dto }
    func output(dto: DTO) throws -> DTO { dto }
    func stdErr(error: Error) -> Error { error }
    
    private func handleReachability(options: [CAUsecaseOption]) throws {
        guard !options.contains(.disableReachability) else {
            return
        }
        guard reachabilityManager.isConnectedToNetwork() else {
            throw CAError.networkIssue
        }
    }
    
    private func sendSnackBarIssue(type: CANotificationManager.AlertType, options: [CAUsecaseOption]) {
        if !options.contains(.disableSnackBar), !options.contains(.disableNotificationCenter) {
//            notificationManager.alert(type: type)
        }
    }
    
    @MainActor
    private func handleError(error: Error, dto: String, options: [CAUsecaseOption]) async -> Error {
        switch error.toCAError {
        case .forbiddenAccess(let request):
            if !options.contains(.disableNotificationCenter) {
                notificationManager.post(id: "forbiddenAccess", value: request)
            }
        case .badRequest(let data):
            guard data == nil else {
                break
            }
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .missingData, .missingDTO, .requestCreate:
            reportManager.pushLocalError(caError: error.toCAError, className: dto)
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .webServiceIssue, .notFound:
            sendSnackBarIssue(type: .webserviceIssue, options: options)
        case .networkIssue:
            sendSnackBarIssue(type: .networkIssue, options: options)
        case .decodableData(request: let request, error: let error, data: let data):
            Task { await reportManager.sendDecodableStrapi(request: request, error: error, json: data) }
        case .timeOut:
            break // report ?
        default:
            break
        }
        return error
    }
    
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO {
        let taskOptions = self.config + options
        
        do {
            let input = try input(dto: dto)
            try handleReachability(options: taskOptions)
            let data = try await dataFetch(dto: input, options: taskOptions)
            let output = try output(dto: data)
            return output
        } catch {
            let caError = stdErr(error: error)
            throw await handleError(error: caError, dto: String(describing: Self.Type.self), options: taskOptions)
        }
    }
}
