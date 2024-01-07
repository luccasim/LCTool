//___FILEHEADER___
//  Template: 5.0

import Foundation

// MARK: - Injection

protocol ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO?, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO
 }

extension CAInjectedValues {
    var key___VARIABLE_ModuleName:identifier___: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
        get { Self[___VARIABLE_ModuleName:identifier___Usecase.self] }
        set { Self[___VARIABLE_ModuleName:identifier___Usecase.self] = newValue }
    }
}

// MARK: - ___VARIABLE_ModuleName:identifier___Usecase

final class ___VARIABLE_ModuleName:identifier___Usecase: ___VARIABLE_ModuleName:identifier___UsecaseProtocol, CAUsecaseProtocol, CAInjectionKey {
        
    static var currentValue: ___VARIABLE_ModuleName:identifier___UsecaseProtocol = ___VARIABLE_ModuleName:identifier___Usecase()
    
    let repository: ___VARIABLE_ModuleName:identifier___RepositoryProtocol
    var config: [CAUsecaseOption] = []
    
    init(repo: ___VARIABLE_ModuleName:identifier___RepositoryProtocol = ___VARIABLE_ModuleName:identifier___Repository(), config: [CAUsecaseOption] = []) {
        self.config = config
        self.repository = repo
    }
    
    func dataFetch(dto: ___VARIABLE_ModuleName:identifier___DTO?, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
        try await repository.dataTaskAsync(dto: dto ?? .init(), options: options)
    }
}

// MARK: - Usecase

extension ___VARIABLE_ModuleName:identifier___Usecase {
    
//    enum Failure: Error {
//
//    }
    
//    func input(dto: ___VARIABLE_ModuleName:identifier___DTO?) throws -> ___VARIABLE_ModuleName:identifier___DTO? {
//        dto
//    }
    
//    func output(dto: ___VARIABLE_ModuleName:identifier___DTO) throws -> ___VARIABLE_ModuleName:identifier___DTO {
//        dto
//    }
    
//    func stdErr(error: Error) -> Error {
//        error
//    }
}
