//___FILEHEADER___
//  Template: 7.0

import Foundation

extension FreeKeychainServiceProtocol {
    
    func get___VARIABLE_ModuleName:identifier___Keychain() async -> String? {
        KeychainService().get(forKey: "___VARIABLE_ModuleName:identifier___")
    }
    
    func set___VARIABLE_ModuleName:identifier___Keychain(_ accessToken: String?) async {
        KeychainService().set(value: accessToken, forKey: "___VARIABLE_ModuleName:identifier___")
    }
}
