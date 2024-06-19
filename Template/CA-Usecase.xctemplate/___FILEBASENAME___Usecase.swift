//___FILEHEADER___
//  Template: 6.0

import Foundation

protocol ___VARIABLE_ModuleName:identifier___RepositoryProtocol {
//    func fetch___VARIABLE_ModuleName:identifier___(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___Response
}

// MARK: - DTO

struct ___VARIABLE_ModuleName:identifier___DTO {

    // Input

    // Output

}

final class ___VARIABLE_ModuleName:identifier___Usecase {
    
    // MARK: - Dependences
    
    var repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol
    
    init(repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Error
    
    enum Failure: Error {
        
    }
    
    // MARK: - Task
    
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
        do {
//            let result = try await repository.getNationalizeName(dto: dto)
            return .init()
        } catch {
            throw error
        }
    }
}
