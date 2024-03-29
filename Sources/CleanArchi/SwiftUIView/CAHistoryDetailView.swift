//
//  CAHistoryDetailView.swift
//  Mon Compte Free
//
//  Created by Free on 16/06/2023.
//

import SwiftUI

struct CAHistoryDetailView: View {
    
    // MARK: - Parameter
    
    let data: CAWebserviceManager.History
            
    // MARK: - Body
    
    var body: some View {
        content
            .navigationTitle(data.serviceDescription)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Views
    
    private var content: some View {
        Form {
            headerCard
            payloadCard
            
            if let jsonData = data.jsonData {
                responseCard(text: jsonData, title: "DATA")
            }
            
            if let error = data.httpErrorDescription {
                responseCard(text: error, title: "ERROR")
            }
        }
    }
    
    private var payloadCard: some View {
        Section {
            VStack(alignment: .leading) {
                if let url = data.request.url?.absoluteString {
                    Text("**URL:** \(url)")
                }
                if let header = data.header {
                    Text("**HTTP HEADER:** \(header)")
                }
                if let method = data.request.httpMethod {
                    Text("**HTTP METHOD:** \(method)")
                }
                if let body = data.requestHttpBody {
                    Text("**HTTP BODY:** \(body)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } header: {
            HStack {
                Text("PAYLOAD")
                Spacer()
                Button {
                    UIPasteboard.general.string = data.request.curlCommand
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var headerCard: some View {
        Section {
            VStack(alignment: .leading) {
                Text("**CODE:** \(data.statusCode.description)")
                Text("**DATE:** \(data.responseDateStr)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } header: {
            Text("Response")
        }
    }
    
    private func responseCard(text: String, title: String) -> some View {
        Section {
            Text(text)
        } header: {
            HStack {
                Text(title)
                Spacer()
                Button {
                    if let json = data.jsonData {
                        UIPasteboard.general.string = json
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } else if let error = data.httpErrorDescription {
                        UIPasteboard.general.string = error
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Previews

struct EndpointHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CAHistoryDetailView(data: .preview())
        }
    }
}

extension CAWebserviceManager.History {
    // swiftlint:disable force_unwrapping
    static func preview() -> Self {
        let url = URL(string: "www.cleanArchi.com")!
        return .init(request: URLRequest(url: url),
                     httpResponse: .init(url: url,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: ["Date": "9/9/99"]),
                     httpData: nil,
                     httpError: nil,
                     description: "Service Preview")
    }
    // swiftlint:enable force_unwrapping
}
