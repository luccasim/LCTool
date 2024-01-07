//
//  Store+CleanArchi.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

import Foundation
import CoreData

// MARK: - Protocol

protocol CAStoreProtocol: AnyObject {
    
    func save(value: Any?, forKey: String)
    func retrieve(forKey: String) -> Any?
    
    func saveCache(value: Any, forKey: String, forTime: TimeInterval?)
    func retrieveCache(forKey: String) -> Any?
    func removeCache(forKey: String)
    
    func saveCodable<T: Codable>(value: T, forKey: String)
    func retrieveCodable<T: Codable>(forKey: String) -> T?
    func removeCodable(forKey: String)
    
    func saveAsEncryption(value: String?, forKey: String)
    func retrieveAsEncryption(forKey: String) -> String?
    func removeAsEncryption(forKey: String)    
}

// MARK: - Store

final class CAStoreManager {
    
    static let shared = CAStoreManager()
    private init() {}
    
    private let writeFileManager = WriteFileManager()
    private let keychainManager = KeychainManager()
    private let cacheManager = ExpireCacheManager()
}

// MARK: - Extension

extension CAStoreManager: CAStoreProtocol {
    
    // MARK: - UserDefault
    
    func save(value: Any?, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    func retrieve(forKey: String) -> Any? {
        UserDefaults.standard.object(forKey: forKey)
    }
    
    // MARK: - Cache
    
    func saveCache(value: Any, forKey: String, forTime: TimeInterval?) {
        cacheManager.set(id: forKey, value: value, limit: forTime)
    }
    
    func retrieveCache(forKey: String) -> Any? {
        cacheManager.get(id: forKey)
    }
    
    func removeCache(forKey: String) {
        cacheManager.set(id: forKey, value: nil)
    }
    
    // MARK: - Codable
    
    func saveCodable<T: Codable>(value: T, forKey: String) {
        writeFileManager.write(codableFileName: forKey, codableData: value)
    }
    
    func retrieveCodable<T: Codable>(forKey: String) -> T? {
        writeFileManager.read(codableFileName: forKey)
    }
    
    func removeCodable(forKey: String) {
        writeFileManager.delete(fileName: forKey)
    }
    
    // MARK: - Encryption
    
    func saveAsEncryption(value: String?, forKey: String) {
        keychainManager.set(value: value, forKey: forKey)
    }
    
    func retrieveAsEncryption(forKey: String) -> String? {
        keychainManager.get(forKey: forKey)
    }
    
    func removeAsEncryption(forKey: String) {
        keychainManager.delete(forKey: forKey)
    }
}
