//
//  ExpireCacheManager.swift
//  Mon Compte Free
//
//  Created by Free on 01/09/2022.
//

import Foundation

protocol ExpireCacheManagerProtocol {
    func set(id: String, value: Any?, limit: TimeInterval?)
    func get(id: String) -> Any?
    func clear()
}

final class ExpireCacheManager {
    
    static let shared = ExpireCacheManager()
    private var cache = [String: (date: Date?, data: Any?)]()
}

extension ExpireCacheManager: ExpireCacheManagerProtocol {
    
    func set(id: String, value: Any?, limit: TimeInterval? = nil) {
        let expireTime = limit.flatMap({Date() + $0})
        self.cache[id] = (expireTime, value)
    }
    
    func get(id: String) -> Any? {
        
        guard let value = self.cache[id] else {
            return nil
        }
        
        guard let expireDate = value.date else {
            return value.data
        }
        
        guard Date() < expireDate else {
            self.cache[id] = nil
            return nil
        }
        let remainingSecondes = Int(expireDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
        print("Cache expire on \(remainingSecondes) secondes")
        return value.data
    }
    
    func clear() {
        cache = [:]
    }
}
