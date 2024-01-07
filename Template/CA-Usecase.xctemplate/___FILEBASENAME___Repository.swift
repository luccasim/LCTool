//___FILEHEADER___
//  Template: 5.0

import Foundation

// MARK: - ___VARIABLE_ModuleName:identifier___RepositoryProtocol

protocol ___VARIABLE_ModuleName:identifier___RepositoryProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO
}

extension ___VARIABLE_ModuleName:identifier___Repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
        webservice.set(options: options)
        return try await fetch(dto: dto)
    }
}

// MARK: - ___VARIABLE_ModuleName:identifier___Repository

final class ___VARIABLE_ModuleName:identifier___Repository {
        
    var store = CAStoreManager.shared
    var webservice = CAURLSessionManager()
    
    // MARK: - Async Endpoint
    
    private func fetchEndpoint(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
        dto
    }
    
    // MARK: - Fetch
    
    private func fetch(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
        do {
            return try await fetchEndpoint(dto: dto)
        } catch let error {
            throw error
        }
    }
}
