//___FILEHEADER___
//  Template: 6.0

import Foundation

struct ___VARIABLE_ModuleName:identifier___DTO {

    // Input

    // Output

}

protocol ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___DTO
}

final class ___VARIABLE_ModuleName:identifier___Usecase {
    
    // MARK: - Dependences
    
    // var exampleRepository = ExampleRepository()
    
    init() {}
    
    // MARK: - Error
    
    enum Failure: Error {
        
    }
    
    // MARK: - Task
    
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO) async throws -> ___VARIABLE_ModuleName:identifier___DTO {
//        do {
//            let result = try await exampleRepository.getExampleName(dto: dto)
//            return .init(exampleResponse: result)
//        } catch {
//            throw error
//        }
        dto
    }
}
