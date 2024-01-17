//
//  File.swift
//  
//
//  Created by Luc on 15/01/2024.
//

import SwiftUI

struct Test: View {
    
    @State private var isAppear = true
    @State private var label = "Button"
    
    var offset: CGFloat {
        isAppear ? 0 : 100.0
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.orange)
                .ignoresSafeArea()
            actionButton
        }
        .onTapGesture {
            isAppear = false
        }
        .overlay(alignment: .bottom) {
            snackbar
        }
    }
    
    var actionButton: some View {
        Button(action: {
            CANotificationManager.shared.post(id: "test", value: "Boobs")
        }, label: {
            Text("push me")
        })
    }
    
    var snackbar: some View {
        SnackBarInfoView(message: "Bonjour TOTO", image: .init(systemName: "doc"))
            .offset(y: offset)
            .animation(.spring, value: offset)
            .onReceive(NotificationCenter.default.publisher(for: .init("test")), perform: { output in
                if let output = output.object as? String {
                    isAppear = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isAppear = false
                    }
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
                .frame(width: 16, height: 16)
            
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
