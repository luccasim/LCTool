//
//  BiometricService.swift
//  Mon Compte Free
//
//  Created by Free on 06/09/2024.
//

import Foundation
import LocalAuthentication

public final class BiometricService {
    
    let localizedReason: String
    
    init(localizedReason: String) {
        // c'est n'importe quoi genre .description c'est trop compliqué
        let localizedKey = String.LocalizationValue(stringLiteral: localizedReason)
        self.localizedReason = String(localized: localizedKey)
    }
    
    func biometricChecking(context: LAContext = LAContext()) async throws -> Bool {
        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason)
    }
    
    func biometricType(context: LAContext = LAContext()) -> LABiometryType {
        context.biometryType
    }
}

// MARK: - Biometric

public extension BiometricService {
    
    func biometricCheck() async throws -> Bool {
        try await self.biometricChecking()
    }
}
