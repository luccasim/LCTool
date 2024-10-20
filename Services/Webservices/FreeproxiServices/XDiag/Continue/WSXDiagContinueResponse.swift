//
//  WSXDiagContinueResponse.swift
//  Mon Compte Free
//
//  Created by Free on 20/06/2023.
//

import Foundation

// MARK: - Codable

struct WSXDiagContinueResponse: Codable {
    
    let instanceID: String?
    let state: [State]?
    let workerID: Int?
    let success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case instanceID = "instance_id"
        case state
        case workerID = "worker_id"
        case success
    }
    
    // MARK: - State
    struct State: Codable {
        let id: String?
        let idx: Int?
        let instanceID: String?
        let action: Action?
        let commited: Bool?
        let creationDate, label, modifDate, name: String?
        let status, transition, transitionLabel, type: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case idx
            case instanceID = "instance_id"
            case action, commited
            case creationDate = "creation_date"
            case label
            case modifDate = "modif_date"
            case name, status, transition
            case transitionLabel = "transition_label"
            case type
        }
    }
    
    // MARK: - Action
    struct Action: Codable {
        let config: Config?
        let archivable: Bool?
        let status: String?
        let pendingStates: [Config]?
        
        enum CodingKeys: String, CodingKey {
            case config, archivable, status
            case pendingStates = "pending_states"
        }
    }
    
    // MARK: - Config
    struct Config: Codable {
        let stepTitle, substepTitle, blocking, choiceType: String?
        let contents: [ConfigContent]?
        let displayField, label: String?
        let subValueField, userInputType, valueField, variable: String?
        let wsvar: String?
        let choiceValues: [ChoiceValue]?
        let idx: Int?
        
        enum CodingKeys: String, CodingKey {
            case stepTitle = "step_title"
            case substepTitle = "substep_title"
            case blocking
            case choiceType = "choice_type"
            case contents
            case displayField = "display_field"
            case label
            case subValueField = "sub_value_field"
            case userInputType = "user_input_type"
            case valueField = "value_field"
            case variable, wsvar
            case choiceValues = "choice_values"
            case idx
        }
    }
    
    // MARK: - ChoiceValue
    struct ChoiceValue: Codable {
        let label, value: String?
        let subValue: [SubValue]?
        
        enum CodingKeys: String, CodingKey {
            case label, value
            case subValue = "sub_value"
        }
    }
    
    // MARK: - SubValue
    struct SubValue: Codable {
        let label, value: String?
    }
    
    // MARK: - ConfigContent
    struct ConfigContent: Codable {
        let id, name: String?
        let type: TypeClass?
        let contents: [ContentContent]?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, type, contents
        }
    }
    
    // MARK: - ContentContent
    struct ContentContent: Codable {
        let contentDescription: String?
        let libs: [String]?
        
        enum CodingKeys: String, CodingKey {
            case contentDescription = "description"
            case libs
        }
    }
    
    // MARK: - TypeClass
    struct TypeClass: Codable {
        let name, type: String?
    }
}
