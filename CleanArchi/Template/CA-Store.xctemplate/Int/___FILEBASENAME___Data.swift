//___FILEHEADER___
//  Template: 7.0

import Foundation

extension String {
    static var castore___VARIABLE_ModuleName:identifier___UserDefaultInt = "___VARIABLE_ModuleName:identifier___Int"
}

extension FreeUserDefaultServiceProtocol {
    
    func get___VARIABLE_ModuleName:identifier___UserDefaultInt() async -> Int {
        UserDefaults.standard.integer(forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultInt)
    }
    
    func set___VARIABLE_ModuleName:identifier___UserDefaultInt(_ value: Int?) async {
        UserDefaults.standard.set(value, forKey: .castore___VARIABLE_ModuleName:identifier___UserDefaultInt)
    }
}
