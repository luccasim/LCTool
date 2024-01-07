//___FILEHEADER___
//  Template: 5.0

import Foundation
import SwiftUI

// MARK: - Environment

extension EnvironmentValues {
    private struct ___VARIABLE_ModuleName:identifier___DataKey: EnvironmentKey { static let defaultValue = ___VARIABLE_ModuleName:identifier___Data() }
    
    var env___VARIABLE_ModuleName:identifier___Preference: ___VARIABLE_ModuleName:identifier___Data {
        get { self[___VARIABLE_ModuleName:identifier___DataKey.self] }
        set { self[___VARIABLE_ModuleName:identifier___DataKey.self] = newValue }
    }
}

// MARK: - Storage

extension CAStoreManager {
    var stored___VARIABLE_ModuleName:identifier___: ___VARIABLE_ModuleName:identifier___Data? {
        get { retrieveCodable(forKey: "stored___VARIABLE_ModuleName:identifier___") }
        set { saveCodable(value: newValue, forKey: "stored___VARIABLE_ModuleName:identifier___") }
    }
    
    var stored___VARIABLE_ModuleName:identifier___Array: [TestData]? {
        get { retrieveCodable(forKey: "stored___VARIABLE_ModuleName:identifier___Array") }
        set { saveCodable(value: newValue, forKey: "stored___VARIABLE_ModuleName:identifier___Array") }
    }
}

// MARK: - ___VARIABLE_ModuleName:identifier___Data

struct ___VARIABLE_ModuleName:identifier___Data: Codable {
        
}
