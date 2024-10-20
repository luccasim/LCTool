//
//  FreeErrorHandlerService.swift
//  Mon Compte Free
//
//  Created by Free on 08/07/2024.
//

import Foundation

final class FreeErrorHandler: CAErrorHandlerServiceProtocol, FreeErrorHandlerProtocol {
    
    // MARK: - Legacy
    
    @available(*, deprecated, message: "💩 -> Cette fonction est appelée par URLSessionService depuis le repository.")
    nonisolated func checkReachability(options: [CAUsecaseOption]) throws {
        guard !options.contains(.disableReachability) else {
            return
        }
        guard ReachabilityManager().isConnectedToNetwork() else {
            throw CAError.networkIssue
        }
    }
    
    @available(*, deprecated, message: "💩 -> Utilise handle(usecase:error:options:) depuis le repository")
    nonisolated func checkError(dto: String, error: Error, options: [CAUsecaseOption]) async -> Error {
        await self.handleError(usecaseName: dto, error: error, options: options)
    }
    
    // MARK: - CAErrorHandlerServiceProtocol
    
    func handle(usecase: Sendable, error: Error, options: [CAUsecaseOption] = []) async -> Error {
        await self.handleError(usecaseName: String(describing: usecase), error: error, options: options)
    }
    
    // MARK: - SnackBar
    
    private enum Alert: String {
        case webserviceIssue, networkIssue
    }
        
    private func sendSnackBarIssue(alert: Alert, options: [CAUsecaseOption]) {
        if !options.contains(.disableSnackBar), !options.contains(.disableNotificationCenter) {
            let snackBarService = SnackBarService()
            switch alert {
            case .webserviceIssue:
                snackBarService.show(type: .webserviceIssue, title: "", message: "")
            case .networkIssue:
                snackBarService.show(type: .networkIssue, title: "", message: "")
            }
        }
    }
    
    // MARK: - NotifcationCenter
    
    private func post(key: String, object: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .init(key), object: object)
        }
    }
    
    // MARK: - CAError
    
    private func mapHttpCode(request: URLRequest, response: URLResponse, data: Data, error: Error) -> Error {
        switch (response as? HTTPURLResponse)?.statusCode {
        case 400:
            return CAError.badRequest(source: data)
        case 401:
            return CAError.unAuthorized(data: data)
        case 403, 503:
            return CAError.forbiddenAccess(request: request, data: data)
        case 404:
            return CAError.notFound
        default:
            return CAError.webServiceIssue
        }
    }
    
    private func mapToBusinessError(error: Error) -> Error {
        switch error as? URLSessionService.Failure {
        case .invalidStatusCode(request: let request, response: let response, data: let data):
            return mapHttpCode(request: request, response: response, data: data, error: error)
        case .missingURI:
            return CAError.missingData
        case .notConnectedToNetwork:
            return CAError.webServiceIssue
        case .decodable(url: let url, error: let error, data: let data, description: _ ):
            return CAError.decodableData(request: URLRequest(url: url), error: error, data: data)
        default:
            return error
        }
    }
    
    private func handleError(usecaseName: String, error: Error, options: [CAUsecaseOption]) async -> Error {
        
        let businessError = mapToBusinessError(error: error)
        let reporter = ReporterService()
                
        post(key: "loggerService",
             object: ("errorHandler", ["caller": usecaseName, "error": error, "businessError": businessError])
        )
        
        guard !options.contains(.disableErrorHandler) else {
            return error
        }
        
        switch businessError.toCAError {
        case .forbiddenAccess(let request, _) where !options.contains(.disableNotificationCenter):
            post(key: "forbiddenAccess", object: request)
        case .badRequest(let source):
            sendSnackBarIssue(alert: .webserviceIssue, options: options)
            await reporter.sendReport(usecaseName: usecaseName,
                                title: "Bad Request Non gérer",
                                text: source.flatMap({String(data: $0, encoding: .utf8)}) ?? "")
        case .missingData, .missingDTO, .requestCreate:
            sendSnackBarIssue(alert: .webserviceIssue, options: options)
            await reporter.sendReport(usecaseName: usecaseName,
                                title: "Dev error",
                                text: "Missing data / DTO / request")
        case .webServiceIssue, .notFound:
            sendSnackBarIssue(alert: .webserviceIssue, options: options)
        case .networkIssue:
            sendSnackBarIssue(alert: .networkIssue, options: options)
        case .decodableData(request: let request, error: let error, data: let data):
            sendSnackBarIssue(alert: .webserviceIssue, options: options)
            await reporter.sendDecodableError(usecaseName: usecaseName, request: request, json: data, error: error)
        case .report(title: let title, message: let message):
            await reporter.sendReport(usecaseName: usecaseName, title: title, text: message)
        case .timeOut:
            break
        default:
            break
        }
        return error
    }
}

// MARK: - Helper

extension Error {
    
    var getURLSessionData: Data? {
        switch self as? URLSessionService.Failure {
        case .invalidStatusCode(request: _, response: _, data: let data):
            return data
        default:
            return nil
        }
    }
    
    var getURLSessionStatusCode: Int? {
        switch self as? URLSessionService.Failure {
        case .invalidStatusCode(request: _, response: let response, data: _):
            return (response as? HTTPURLResponse)?.statusCode
        default:
            return nil
        }
    }
}
