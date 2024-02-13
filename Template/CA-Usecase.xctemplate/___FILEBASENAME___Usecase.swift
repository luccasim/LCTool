//___FILEHEADER___
//  Template: 6.0

import Foundation
import LCTool

extension CAInjectedValues {
    var key___VARIABLE_ModuleName:identifier___: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
        get { Self[___VARIABLE_ModuleName:identifier___Usecase.self] }
        set { Self[___VARIABLE_ModuleName:identifier___Usecase.self] = newValue }
    }
}

@Usecase
protocol ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO?, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO
 }

@Usecase
final class ___VARIABLE_ModuleName:identifier___Usecase: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
    
    // MARK: - Postman
        
    enum Key: String, CaseIterable, PostmanKey {
        case prod
    }
    
    // MARK: - Error
    
    enum Failure: Error {
        
    }
}
