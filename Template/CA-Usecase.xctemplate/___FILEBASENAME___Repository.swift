//___FILEHEADER___
//  Template: 6.0

import Foundation
import LCTool

// MARK: - ___VARIABLE_ModuleName:identifier___RepositoryProtocol

protocol ___VARIABLE_ModuleName:identifier___RepositoryProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO
}

// MARK: - ___VARIABLE_ModuleName:identifier___Repository

@Repository
final class ___VARIABLE_ModuleName:identifier___Repository {
    
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
