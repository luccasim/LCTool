//___FILEHEADER___
//  Template: 5.0

import Foundation

// MARK: - CAPreview

extension ___VARIABLE_ModuleName:identifier___Preview: CAPreviewProtocol {
    var keys: [CAPreviewKey] { Key.allCases.map({ .init(label: $0.label, key: $0.rawValue) }) }
    var options: [CAUsecaseOption] { self.key == .prod ? [] : [ .useTestUIServer(mock: self.key.rawValue) ] }

    func dataTaskAsync(dto: ___VARIABLE_ModuleName:identifier___DTO?, options: [CAUsecaseOption]) async throws -> ___VARIABLE_ModuleName:identifier___DTO { 
        switch self.key.value {
        case .none: return try await ___VARIABLE_ModuleName:identifier___Usecase().dataTaskAsync(dto: dto, options: options + self.options)
        default: return key.value ?? .init()
        }
    }

    func inject(key: String? = nil) {
        self.key = key.flatMap({.init(rawValue: $0)}) ?? self.key
        ___VARIABLE_ModuleName:identifier___Usecase.currentValue = switch self.key.value {
        case .none: ___VARIABLE_ModuleName:identifier___Usecase(config: options)
        default: self
        }
    }
}

// MARK: - ___VARIABLE_ModuleName:identifier___Preview

final class ___VARIABLE_ModuleName:identifier___Preview: ___VARIABLE_ModuleName:identifier___UsecaseProtocol {
        
    private var key: Key = .prod
    
    init(key: Key = .prod) {
        self.key = key
    }
    
    // MARK: - Key
    
    enum Key: String, CaseIterable {
        
        case prod
        
        // Key label for CAPreviewPicker
        var label: String {
            switch self {
            default: return self.rawValue
            }
        }
        
        // Preview local value.
        var value: ___VARIABLE_ModuleName:identifier___DTO? {
            switch self {
            default: return nil
            }
        }
    }
}
