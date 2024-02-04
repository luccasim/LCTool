//___FILEHEADER___
//  Template: 6.0

import Foundation
import LCTool

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

@Usecase
final class ___VARIABLE_ModuleName:identifier___Usecase: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
        
    enum Key: String, CaseIterable {
        
        case prod
        
        var label: String {
            switch self {
            case .prod: return "Production"
            default: return self.rawValue
            }
        }
    }
}
