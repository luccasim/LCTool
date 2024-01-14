//
//  KeychainManager.swift
//  Mon Compte Free
//
//  Created by Free on 21/09/2021.
//

import Security
import Foundation

protocol KeychainManagerGenericPasswordProtocol {
    func get(forKey: String) -> String?
    func set(value: String?, forKey: String)
    func delete(forKey: String)
}

final class KeychainManager {
    
    static let shared = KeychainManager()
    private let id = Bundle.main.bundleIdentifier
    
    var appID: String {
        id ?? ""
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

extension KeychainManager: KeychainManagerGenericPasswordProtocol {
    
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
