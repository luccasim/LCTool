//
//  ReporterService.swift
//  Mon Compte Free
//
//  Created by Free on 11/10/2024.
//

import Foundation

actor ReporterService: FreeReportServiceProtocol {
    
    func sendReport(usecaseName: String, title: String, text: String) {
        Task {
            let header = [
                "platform": "iOS",
                "type": "text",
                "title": title,
                "service": usecaseName,
                "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            ]
            
            let path = "/report".hostPath(.cms)
            
            struct Report: Codable {
                let report: String
            }
            
            guard let request = URLRequest(path: path, parameters: nil, queries: [:], httpMethod: .post, header: header,
                                           jsonBody: try? JSONEncoder().encode(Report.init(report: text))) else { return }
            _ = try await URLSession.shared.data(for: request)
        }
    }
    
    func sendDecodableError(usecaseName: String, request: URLRequest, json: Data, error: Error) {
        Task {
            var title = "Une erreur de décodage s'est produite"
            var comment = ""
            let sourceURL = request.url?.absoluteString ?? "#missingURL"
            
            switch error as? DecodingError {
            case .typeMismatch(_, let value):
                let key = value.codingPath.last?.stringValue ?? "#keyNotFound"
                comment = "\(key);\(value.debugDescription);\(sourceURL)"
                title += ": Mismatch"
            case .keyNotFound(let key, let context):
                comment = "\(key);\(context.debugDescription);\(sourceURL)"
                title += ": Key not found"
            case .valueNotFound(let value, let context):
                comment = "\(value);\(context.debugDescription);\(sourceURL)"
                title += ": Value not found"
            case .dataCorrupted(let context):
                comment = "notkey;\(context.debugDescription);\(sourceURL)"
                title += ": Data corrupted"
            default:
                break
            }
            
            let header = [
                "platform": "iOS",
                "type": "decodable",
                "title": title,
                "service": usecaseName,
                "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                "comment": comment
            ]
            
            let path = "/report".hostPath(.cms)
            
            guard let request = URLRequest(path: path, parameters: nil, queries: [:], httpMethod: .post, header: header,
                                    jsonBody: json) else { return }
            
            _ = try await URLSession.shared.data(for: request)
        }
    }
}
