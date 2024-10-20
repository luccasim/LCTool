//
//  CAUsecase.swift
//  Mon Compte Free
//
//  Created by Free on 03/11/2023.
//

import Foundation

protocol CAUsecaseProtocol: AnyObject, Sendable {
    
    associatedtype DTO
    
    var reachabilityManager: CAReachabilityProtocol { get }
    var storeManager: CAStoreService { get }
    
    func input(dto: DTO?) throws -> DTO?
    func output(dto: DTO) throws -> DTO
    func stdErr(error: Error) -> Error
    
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    func dataFetch(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO
    
}

extension CAUsecaseProtocol {
    
    var reachabilityManager: CAReachabilityProtocol { ReachabilityManager.shared }
    var storeManager: CAStoreService { CAStoreService() }
    
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
        
    func dataTaskAsync(dto: DTO?, options: [CAUsecaseOption]) async throws -> DTO {
        let taskOptions = options
        
        do {
            let input = try input(dto: dto)
            try handleReachability(options: taskOptions)
            let data = try await dataFetch(dto: input, options: taskOptions)
            let output = try output(dto: data)
            return output
        } catch {
            throw await FreeErrorHandler().handle(usecase: self, error: error, options: options)
        }
    }
}
