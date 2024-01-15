//
//  File.swift
//  
//
//  Created by Luc on 15/01/2024.
//

import SwiftUI

struct Test: View {
    
    @State private var label = "Button"
    
    var body: some View {
        Button(action: {
            CANotificationManager.shared.post(id: "test", value: "Boobs")
        }, label: {
            ZStack {
                Rectangle()
                    .fill(Color.orange)
                    .ignoresSafeArea(.all)
                    .overlay(
                        SnackBarInfoView(message: "Bonjour", image: .init(systemName: "row"))
                            .offset(y: -100)
                        .alignmentGuide(.bottom) {$0[.top]},
                      alignment: .center
                    )
                Text(label)
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .init("test")), perform: { output in
            if let output = output.object as? String {
                self.label = output
            }
        })
    }
}

struct SnackBarInfoView: View {
    
    let message: String
    let image: Image
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            image
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.white)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal)
        .background(background)
    }
    
    // MARK: - Methods
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray)
            .frame(height: 24)
    }
}

#Preview {
    Test()
}
