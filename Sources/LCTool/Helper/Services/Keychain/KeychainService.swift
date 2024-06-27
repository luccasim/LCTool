//
//  KeychainService.swift
//  Mon Compte Free
//
//  Created by Free on 21/09/2021.
//

import Security
import Foundation
import LocalAuthentication

protocol KeychainServiceProtocol {
    // Access with Biometric
    func addCredentialWithBiometric(server: String, credentials: KeychainService.Credentials) throws
    func getCredentialWithBiometric(server: String) throws -> KeychainService.Credentials
    func deleteCredentialWithBiometric(server: String) throws
    
    // Store as Generic
    func get(forKey: String) -> String?
    func set(value: String?, forKey: String)
    func delete(forKey: String)
}

final class KeychainService {
    
    static let shared = KeychainService()
    
    var appID: String {
        Bundle.main.bundleIdentifier ?? ""
    }
    
    // MARK: - Keychain with Biometric
    
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/adding_a_password_to_the_keychain
    struct Credentials {
        var username: String
        var password: String
    }
    
    struct KeychainError: Error {
        var status: OSStatus

        var localizedDescription: String {
            SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    func addCredentialWithBiometric(server: String, credentials: Credentials) throws {
        guard let pwd = credentials.password.data(using: String.Encoding.utf8) else {
            return
        }
        
        let context = LAContext()
        let access = SecAccessControlCreateWithFlags(nil,
                                                     kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                     .userPresence,
                                                     nil)
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: pwd]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }
    
    func getCredentialWithBiometric(server: String) throws -> Credentials {
        
        let context = LAContext()
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError(status: errSecInternalError)
        }
        return .init(username: account, password: password)
    }
    
    /// Deletes credentials for the given server.
    func deleteCredentialWithBiometric(server: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { 
            throw KeychainError(status: status)
        }
    }
    
    // MARK: - Store as Generic Password
    
    func addGenericPassword(value: String, key: String) {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: appID,
            kSecValueData as String: value.data(using: .utf8) ?? ""
        ]

        _ = SecItemAdd(query as CFDictionary, nil)
    }
    
    func getGenericPassword(key: String) -> String? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: appID,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var item: AnyObject?

        _ = SecItemCopyMatching(query as CFDictionary, &item)

        return (item as? Data).flatMap({String(data: $0, encoding: .utf8)})
    }
    
    func updateGenericPassword(value: String, key: String) {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: appID
        ]
        
        let attributes: [String: Any] = [kSecValueData as String: value.data(using: .utf8) ?? ""]
        _ = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
    
    func deleteGenericPassword(key: String) {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: appID
        ]
        
        _ = SecItemDelete(query as CFDictionary)
    }
}

extension KeychainService: KeychainServiceProtocol {
    
    func get(forKey: String) -> String? {
        return getGenericPassword(key: forKey)
    }
    
    func set(value: String?, forKey: String) {
        guard let newValue = value else {
            return delete(forKey: forKey)
        }
        
        guard let currentValue = getGenericPassword(key: forKey) else {
            return addGenericPassword(value: newValue, key: forKey)
        }
        
        if currentValue != newValue {
            updateGenericPassword(value: newValue, key: forKey)
        }
    }
    
    func delete(forKey: String) {
        deleteGenericPassword(key: forKey)
    }
}