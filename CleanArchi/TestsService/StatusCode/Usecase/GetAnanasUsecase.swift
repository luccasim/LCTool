//
//  GetAnanasUsecase.swift
//  Integration
//
//  Created by Free on 22/09/2024.
//
//  Template: 7.0

import Foundation

protocol GetAnanasUsecaseProtocol: Sendable {
    func bipbip(input: GetAnanasUsecase.Input) async throws -> GetAnanasUsecase.Result
 }

/// What this usecase do ?
final class GetAnanasUsecase: GetAnanasUsecaseProtocol {
            
    // MARK: - Dependances

    private let repository: FreeRepositoryProtocol
    
    // MARK: - Injection
    
    init(repository: FreeRepositoryProtocol? = nil) {
        self.repository = repository ?? FreeRepository()
    }
    
    // MARK: - Input

    struct Input {
        let id: Int
    }

    // MARK: - Result

    struct Result: Codable {
        let mandatory, optional: String
    }
    
    // MARK: - Failure
    
    enum Failure: Error {
        case missingInput
    }
    
    // MARK: - DataTask
    
    @discardableResult
    func bipbip(input: GetAnanasUsecase.Input) async throws -> GetAnanasUsecase.Result {
        do {
            let path = "https://0f8bd813-20e2-48db-8d49-4aeda939786b.mock.pstmn.io/version/iOS?id=\(input.id.description)".toRequest
            let result: Result = try await repository.urlSessionService.fetchJSON(request: path)
            return result
        } catch {
            if let data = error.getURLSessionData, error.getURLSessionStatusCode == 400 {
                print(data.prettyJSONString)
            }
            throw await repository.errorHandler.handle(usecase: self, error: error, options: [])
        }
    }
}
