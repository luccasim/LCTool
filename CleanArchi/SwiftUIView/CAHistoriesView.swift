//
//  CAHistoriesView.swift
//  Mon Compte Free
//
//  Created by Free on 15/06/2023.
//

import SwiftUI

struct CAHistoriesView: View {
    
    // MARK: - Parameter
    
    @StateObject private var wsManager: CAWebserviceManager
    var font: Font?
    
    init(manager: CAWebserviceManager = .shared, font: Font? = nil) {
        _wsManager = StateObject(wrappedValue: manager)
        self.font = font
    }
        
    // MARK: - Body
    
    var body: some View {
        content
            .font(font)
    }
    
    // MARK: - Views
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(wsManager.histories.reversed(), id: \.id) {
                    cell(data: $0)
                }
            }
        }
        .padding()
    }
    
    func cell(data: CAWebserviceManager.History) -> some View {
        NavigationLink {
                CAHistoryDetailView(data: data)
                    .font(font)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("**\(data.serviceDescription)**")
                }
                HStack {
                    Text("*\(data.responseDateStr)*")
                    Spacer()
                    Circle()
                        .frame(width: 16)
                        .foregroundColor(data.statusCode == 200 ? .green : .yellow)
                }
            }
            .padding()
            .background(Color.white.cornerRadius(10))
            .clipped()
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Previews

struct EndpointHistoriesView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            CAHistoriesView(manager: .preview(), font: .subheadline)
                .navigationTitle("Historique des rêquetes")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension CAWebserviceManager {
    
    static func preview() -> CAWebserviceManager {
        let manager = CAWebserviceManager()
        manager.histories = (0...10).compactMap {
            guard let url = URL(string: "https://www.test.fr/\($0)") else {
                return nil
            }
            return .init(request: URLRequest(url: url),
                         httpResponse: .init(url: url,
                                             statusCode: $0 % 4 == 0 ? 400 : 200,
                                             httpVersion: nil,
                                             headerFields: ["Date": "\($0)/9/99"]),
                         httpData: nil,
                         httpError: nil,
                         description: "Service \($0)")
        }
        return manager
    }
    
}
