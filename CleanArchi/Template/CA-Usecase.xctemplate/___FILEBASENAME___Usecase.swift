//___FILEHEADER___
//  Template: 7.0

import Foundation

protocol ___VARIABLE_ModuleName:identifier___UsecaseProtocol: Sendable {
    func execute(input: ___VARIABLE_ModuleName:identifier___Usecase.Input) async throws -> ___VARIABLE_ModuleName:identifier___Usecase.Result
 }

/// <#What this usecase do ? #>
final class ___VARIABLE_ModuleName:identifier___Usecase: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
            
    // MARK: - Dependances

    private let repository: FreeRepositoryProtocol
        
    init(repository: FreeRepositoryProtocol? = nil) {
        self.repository = repository ?? FreeRepository()
    }
    
    // MARK: - DTO

    struct Input {

    }

    struct Result {
        
    }
    
    // MARK: - Failure
    
    enum Failure: Error {
        case missingInput
    }
    
    // MARK: - DataTask
    
    @discardableResult
    func execute(input: ___VARIABLE_ModuleName:identifier___Usecase.Input) async throws -> ___VARIABLE_ModuleName:identifier___Usecase.Result {
        do {
            throw Failure.missingInput
        } catch {
            throw await repository.errorHandler.handle(usecase: self, error: error, options: [])
        }
    }
}
