//
//  Codable+Property.swift
//  Mon Compte Free
//
//  Created by Free on 29/08/2022.
//

import Foundation

enum CodableAny: Codable {
    
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode DataType")
        }
    }
    
    var double: Double? {
        switch self {
        case .double(let value):
            return value
        default:
            return nil
        }
    }
    
    var int: Int? {
        switch self {
        case .int(let value):
            return value
        default:
            return nil
        }
    }
    
    var string: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    
    var bool: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }
}

// MARK: - Codable Int

@propertyWrapper
struct CodableStr: Codable {
    var wrappedValue: String?
    
    init(from decoder: Decoder) throws {
        do {
            let value = try decoder.singleValueContainer().decode(EnumStr.self)
            switch value {
            case .int(let value):
                wrappedValue = value.description
            case .str(let value):
                wrappedValue = value
            }
        } catch {
            wrappedValue = nil
        }
    }
    
    private enum EnumStr: Codable {
        case str(String?)
        case int(Int)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                self = .str(value)
                return
            }
            if let value = try? container.decode(Int.self) {
                self = .int(value)
                return
            }
            throw DecodingError.typeMismatch(EnumStr.self, .init(codingPath: decoder.codingPath,
                                                                     debugDescription: "Wrong type"))
        }
    }
}

@propertyWrapper
struct CodableBool: Codable {
    var wrappedValue: Bool?
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer().decode(EnumBool.self)
            switch container {
            case .bool(let value):
                wrappedValue = value
            case .int(let value):
                wrappedValue = value == 1 ? true : false
            case .string(let value):
                wrappedValue = value == "1" ? true : false
            }
        } catch {
            wrappedValue = nil
        }
    }
    
    private enum EnumBool: Codable {
        case int(Int)
        case bool(Bool)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Int.self) {
                self = .int(value)
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
                return
            }
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }
            throw DecodingError.typeMismatch(EnumBool.self, .init(codingPath: decoder.codingPath,
                                                                  debugDescription: "Wrong type"))
        }
    }
}

@propertyWrapper
struct CodableInt: Codable {
    
    var wrappedValue: Int?
    
    init(from decoder: Decoder) throws {
        do {
            let value = try decoder.singleValueContainer().decode(EnumInt.self)
            switch value {
            case .int(let value):
                wrappedValue = value
            case .str(let value):
                wrappedValue = Int(value)
            case .bool(let value):
                wrappedValue = value ? 1 : 0
            }
        } catch {
            wrappedValue = nil
        }
    }
    
    private enum EnumInt: Codable {
        case str(String)
        case int(Int)
        case bool(Bool)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                self = .str(value)
                return
            }
            if let value = try? container.decode(Int.self) {
                self = .int(value)
                return
            }
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
                return
            }
            throw DecodingError.typeMismatch(EnumInt.self, .init(codingPath: decoder.codingPath,
                                                                     debugDescription: "Wrong type"))
        }
    }
}
