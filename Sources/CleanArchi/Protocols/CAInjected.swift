//
//  CAInjected.swift
//  Mon Compte Free
//
//  Created by Free on 13/12/2022.
//

import Foundation
import SwiftUI

// MARK: - Key

public protocol CAInjectionKey {

    associatedtype Value

    static var currentValue: Self.Value { get set }
}

// MARK: - Injected values

struct CAInjectedValues {
    
    static var current = CAInjectedValues()
    
    static subscript<K>(key: K.Type) -> K.Value where K: CAInjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    static subscript<T>(_ keyPath: WritableKeyPath<CAInjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

// MARK: - Injection wrapper

@propertyWrapper
struct Injected<T> {
    
    private let keyPath: WritableKeyPath<CAInjectedValues, T>
    
    var wrappedValue: T {
        get { CAInjectedValues[keyPath] }
        set { CAInjectedValues[keyPath] = newValue }
    }
    
    init(_ keyPath: WritableKeyPath<CAInjectedValues, T>) {
        self.keyPath = keyPath
    }
}
