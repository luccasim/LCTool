//
//  CAHistoriesView.swift
//  Mon Compte Free
//
//  Created by Free on 15/06/2023.
//

import SwiftUI

struct CAHistoriesView: View {
    
    // MARK: - Parameter
    
    var logs: [LoggerService.NetworkLog]
        
    // MARK: - Body
    
    var body: some View {
        content
    }
    
    // MARK: - Views
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .tiny) {
                ForEach(logs.reversed(), id: \.id) {
                    cell(data: $0)
                }
            }
        }
        .padding()
    }
    
    func cell(data: LoggerService.NetworkLog) -> some View {
        NavigationLink {
            CAHistoryDetailView(data: data)
        } label: {
            VStack(alignment: .leading, spacing: .tiny) {
                HStack {
                    if data.mime == "png" || data.mime == "jpeg", let file = data.request.url?.lastPathComponent {
                        Text("**\(file)**")
                    } else {
                        Text("**\(data.serviceDescription)**")
                    }
                    if let env = data.env?.uppercased() {
                        Spacer()
                        Text("\(env)")
                    }
                }
                HStack {
                    Text("*\(data.responseDateStr)*")
                    Spacer()
                    Circle()
                        .frame(width: .small)
                        .foregroundColor(statusColor(data: data))
                }
            }
            .padding()
            .background(Color.white.cornerRadius(10))
            .clipped()
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
    
    func statusColor(data: LoggerService.NetworkLog) -> Color {
        switch data.statusCode {
        case 200:
            Color.green
        case 201...300:
            Color.yellow
        default:
            Color.red
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        CAHistoriesView(logs: [])
            .navigationTitle("Historique des rêquetes")
            .navigationBarTitleDisplayMode(.inline)
    }
}
