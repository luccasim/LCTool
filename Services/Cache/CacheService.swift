//
//  CacheService.swift
//  Mon Compte Free
//
//  Created by Free on 04/09/2024.
//

import Foundation

actor CacheService {
    
    private var cache = NSCache<NSString, Entry>()
    
    actor Entry {
        let value: Sendable
        let expireDate: Date?
        
        init(value: Sendable, expireDate: Date?) {
            self.value = value
            self.expireDate = expireDate
        }
        
        var remainingSeconds: Int? {
            expireDate.flatMap({Int($0.timeIntervalSince1970 - Date().timeIntervalSince1970)})
        }
    }
    
    func set(id: String, value: Sendable, limit: TimeInterval? = nil) {
        let expireTime = limit.flatMap({ Date().addingTimeInterval($0) })
        
        self.cache.setObject(Entry(value: value, expireDate: expireTime), forKey: id as NSString)
    }
    
    func get(id: String) -> Sendable? {
        let key = id as NSString
        
        guard let obj = self.cache.object(forKey: key) else {
            return nil
        }
        
        guard let expireDate = obj.expireDate else {
            return obj.value
        }
        
        if Date() >= expireDate {
            self.cache.removeObject(forKey: key)
            return nil
        }
        
        return obj.value
    }
    
    func clear() {
        self.cache.removeAllObjects()
    }
}

// MARK: - Cache

extension CacheService: FreeCacheProtocol {}
