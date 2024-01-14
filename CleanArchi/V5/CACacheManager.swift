//
//  CACacheManager.swift
//  Mon Compte Free
//
//  Created by Free on 26/10/2021.
//

import Foundation

protocol CACacheProtocol {
    subscript(key: String) -> Any? { get }
    subscript(key: String, limit: TimeInterval?) -> Any? { get set }
}

final class CACacheManager: CACacheProtocol {
    
    // MARK: - Properties
    
    static let shared = CACacheManager()
    fileprivate var cache = [String: (date: Date?, data: Any?)]()
    
    subscript(key: String) -> Any? {
        self[key, nil]
    }
    
    subscript(key: String, limit: TimeInterval? = nil) -> Any? {
        get {
            guard let value = self.cache[key] else {
                return nil
            }
            
            guard let expireDate = value.date else {
                return value.data
            }
            
            guard Date() < expireDate else {
                self.cache[key] = nil
                return nil
            }
            let remainingSecondes = Int(expireDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
            debug("CACacheManager '\(key)' expire on \(remainingSecondes) secondes")
            return value.data
        }
        set {
            if let expireDate = limit.flatMap({Date() + $0}) {
                self.cache[key] = (expireDate, newValue)
                debug("CACacheManager '\(key)' set for \(expireDate) secondes")
            }
        }
    }
}
