//
//  Store+CleanArchi.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - Protocol

protocol CAStoreProtocol: AnyObject {
    
    func save(value: StoreValue?, forKey: String) async
    func retrieve(forKey: String) async -> StoreValue?
    
    func saveCache<T: Sendable>(value: T, forKey: String, forTime: TimeInterval?) async
    func retrieveCache<T: Sendable>(forKey: String) async -> T?
    func removeCache(forKey: String) async
    
    func saveCodable<T: Codable & Sendable>(value: T, forKey: String) async
    func retrieveCodable<T: Codable & Sendable>(forKey: String) async -> T?
    func removeCodable(forKey: String) async
    
    func saveAsEncryption(value: String?, forKey: String) async
    func retrieveAsEncryption(forKey: String) async -> String?
    func removeAsEncryption(forKey: String) async
}

// MARK: - Store

actor CAStoreService: FreeUserDefaultServiceProtocol {
    
    private let writeFileManager = WriteFileManager()
    private let keychainManager = KeychainService()
    private let cacheManager = ExpireCacheManager()
        
}

extension EnvironmentValues {
    private struct CAStoreServiceKey: EnvironmentKey { static let defaultValue = CAStoreService() }
    
    var caStore: CAStoreService {
        get { self[CAStoreServiceKey.self] }
        set { self[CAStoreServiceKey.self] = newValue }
    }
}

// MARK: - Extension

extension CAStoreService: CAStoreProtocol {
    
    // MARK: - UserDefault
    
    func save(value: StoreValue?, forKey: String) {
        switch value {
        case .string(let str):
            UserDefaults.standard.set(str, forKey: forKey)
        case .int(let intVal):
            UserDefaults.standard.set(intVal, forKey: forKey)
        case .bool(let boolVal):
            UserDefaults.standard.set(boolVal, forKey: forKey)
        default:
            UserDefaults.standard.removeObject(forKey: forKey)
        }
    }
    
    func retrieve(forKey: String) -> StoreValue? {
        if let str = UserDefaults.standard.string(forKey: forKey) {
            return .string(str)
        } else if let intVal = UserDefaults.standard.value(forKey: forKey) as? Int {
            return .int(intVal)
        } else if let boolVal = UserDefaults.standard.value(forKey: forKey) as? Bool {
            return .bool(boolVal)
        }
        return nil
    }
    
    // MARK: - Cache
    
   func saveCache<T: Sendable>(value: T, forKey: String, forTime: TimeInterval?) {
        cacheManager.set(id: forKey, value: value, limit: forTime)
    }
    
    func retrieveCache<T: Sendable>(forKey: String) -> T? {
        cacheManager.get(id: forKey) as? T
    }
    
    func removeCache(forKey: String) {
        cacheManager.set(id: forKey, value: nil)
    }
    
    // MARK: - Codable
    
    func saveCodable<T: Codable>(value: T, forKey: String) {
        writeFileManager.write(codableFileName: forKey, codableData: value)
    }
    
    func retrieveCodable<T: Codable & Sendable>(forKey: String) -> T? {
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

enum StoreValue: Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
}
