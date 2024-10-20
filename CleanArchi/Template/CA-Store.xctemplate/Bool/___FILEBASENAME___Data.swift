//___FILEHEADER___
//  Template: 7.0

import Foundation

extension String {
    static var castore___VARIABLE_ModuleName:identifier___UserDefaultBool = "___VARIABLE_ModuleName:identifier___Bool"
}

extension FreeUserDefaultServiceProtocol {
    
    func get___VARIABLE_ModuleName:identifier___UserDefaultBool() async -> Bool {
        UserDefaults.standard.bool(forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultBool)
    }
    
    func set___VARIABLE_ModuleName:identifier___UserDefaultBool(_ value: Bool?) async {
        UserDefaults.standard.set(value, forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultBool)
    }
    
}
