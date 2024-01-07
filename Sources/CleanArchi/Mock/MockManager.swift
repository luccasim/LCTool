//
//  MockManager.swift
//  Mon Compte Free
//
//  Created by Free on 05/07/2023.
//

import Foundation

protocol CAFakerProtocol {
    associatedtype DTO
    static var fakes: [String: DTO] {get}
    var devModePath: String {get}
}

extension CAFakerProtocol {
    var devModePath: String { "useless for v 4.1 +" }
}

protocol CAMockProtocol {
    var keys: [String] {get}
    var description: String {get}
    var injectionKey: String {get}
    func inject(key: String)
    func preview()
    func clean()
    func registerToManager()
}

extension CAMockProtocol {
    
    var injectionKey: String {"Not set"}
    func preview() {}
}

final class CAMockManager: ObservableObject {
    
    static var shared = CAMockManager()
    @Published var allMocks = [String: CAMockProtocol]()
    
    func add(mock: CAMockProtocol) {
        allMocks[mock.description] = mock
    }
}
