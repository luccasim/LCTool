//___FILEHEADER___
//  Template: 6.0

import Foundation

// MARK: - Interfaces

protocol ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___Usecase.DTO) async throws -> ___VARIABLE_ModuleName:identifier___Usecase.DTO
}

protocol ___VARIABLE_ModuleName:identifier___RepositoryProtocol {
    
}

final class ___VARIABLE_ModuleName:identifier___Usecase {
    
    // MARK: - Dependences
    
    var repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol
    
    init(repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - DTO
    
    struct DTO {

        // Input

        // Output

    }
    
    // MARK: - Error
    
    enum Failure: Error {
        case missingInputs
    }
    
    // MARK: - Task

    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___Usecase.DTO) async throws -> ___VARIABLE_ModuleName:identifier___Usecase.DTO {
        return .init()
    }
}
