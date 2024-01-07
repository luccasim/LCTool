//
//  CAEndpoint.swift
//  Mon Compte Free
//
//  Created by Free on 19/10/2023.
//

import Foundation
import SwiftUI

public protocol CAEndpointProtocol {
    associatedtype T: Codable
    var request: URLRequest? { get }
    func preview() -> AnyView
}

public extension CAEndpointProtocol {
    func preview() -> AnyView {
        AnyView(EndpointView(endpoint: self))
    }
}

private struct EndpointView: View {
    
    @State private var text = ""
    var endpoint: any CAEndpointProtocol
    var webservice = CAURLSessionManager()
                    
    var body: some View {
        ScrollView {
            Text(text)
                .task {
                    do {
                        text = try await webservice.jsonTask(endpoint: endpoint).prettyJSON ?? "Empty"
                    } catch {
                        text = "Error"
                    }
                }
        }
    }
}

extension Encodable {
    
    var prettyJSON: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Erreur lors de l'encodage JSON : \(error)")
        }

        return nil
    }
}
