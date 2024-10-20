//___FILEHEADER___
//  Template: 7.0

import Foundation

extension String {
    static var castore___VARIABLE_ModuleName:identifier___UserDefaultStr = "___VARIABLE_ModuleName:identifier___Str"
}

extension FreeUserDefaultServiceProtocol {
    
    func get___VARIABLE_ModuleName:identifier___UserDefaultStr() async -> String? {
        UserDefaults.standard.string(forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultStr)
    }
    
    func set___VARIABLE_ModuleName:identifier___UserDefaultStr(_ value: String?) async {
        UserDefaults.standard.set(value, forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultStr)
    }
    
}
