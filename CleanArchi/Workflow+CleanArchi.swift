//
//  WorkflowProtocol+Combine.swift
//  TestLint
//
//  Created by Free on 06/12/2022.
//

import Foundation
import Combine

// MARK: - Usecase Protocol

protocol WorkflowProtocol {
    
    associatedtype Domain

    func dataWorkflow(dto: Domain?) -> AnyPublisher<Domain, CAError>
    func dataFetch(dto: Domain?) -> AnyPublisher<Domain, Error>
    
    func evaluate(dto: Domain) throws -> Domain
        
    var enableSnackBarHandler: Bool {get}
    func input(dto: Domain?) throws -> Domain?
    func output(dto: Domain) throws -> Domain
    func output(error: Error) -> Domain?
}

extension WorkflowProtocol {
    
    func evaluate(dto: Domain) throws -> Domain {
        return dto
    }
    
    var enableSnackBarHandler: Bool {
        true
    }
    
    func input(dto: Domain?) throws -> Domain? {
        return dto
    }
    
    func output(dto: Domain) throws -> Domain {
        return try evaluate(dto: dto)
    }
    
    func output(error: Error) -> Domain? {
        nil
    }
    
    private func sendSnackBarIssue(type: NotificationCenter.AlertType) {
        if enableSnackBarHandler {
            NotificationCenter.show(type: type)
        }
    }
    
    private func handleDomainFailure(dto: String, error: Error) throws -> AnyPublisher<Domain, Error> {
        Future<Domain, Error> { promise in
            
            DispatchQueue.main.async {
                switch error.toCAError {
                case .forbiddenAccess(let request, data: _):
                    NotificationCenter.default.post(name: .init("forbiddenAccess"), object: request)
                case .missingData, .missingDTO, .requestCreate:
                    sendSnackBarIssue(type: .webserviceIssue)
                case .webServiceIssue, .notFound:
                    sendSnackBarIssue(type: .webserviceIssue)
                case .networkIssue:
                    sendSnackBarIssue(type: .networkIssue)
                default:
                    break
                }
                
                if let newDto = output(error: error) {
                    promise(.success(newDto))
                } else {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func dataWorkflow(dto: Domain?) -> AnyPublisher<Domain, CAError> {
        Future<Domain?, Error> { promise in
            promise(ReachabilityManager.shared.isConnectedToNetwork() ? .success(dto) : .failure(CAError.networkIssue))
        }
        .tryMap { _ in
            try input(dto: dto)
        }
        .flatMap { _ in
            dataFetch(dto: dto)
        }
        .tryMap { result in
            try output(dto: result)
        }
        .tryCatch { error -> AnyPublisher<Domain, Error> in
            try handleDomainFailure(dto: String(describing: Self.Type.self), error: error)
        }
        .mapError { error in
            error.toCAError
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
