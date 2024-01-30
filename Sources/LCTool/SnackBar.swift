//
//  File.swift
//  
//
//  Created by Luc on 15/01/2024.
//

import SwiftUI

public struct SnackBarInfo {
    let message: String
    let image: Image?
    var backgroundColor: Color = .gray
}

// MARK: - Views

private struct SnackBarInfoViewModifier: ViewModifier {
    
    @State private var info: SnackBarInfo = .init(message: "", image: nil)
    @State private var isAppear = false
    
    var offset: CGFloat {
        isAppear ? 0 : 100.0
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                SnackBarView(info: info)
                    .offset(y: offset)
                    .animation(.spring, value: offset)
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("LCTool.SnackBarInfoViewModifier"))) { output in
                if let info = output.object as? SnackBarInfo {
                    self.info = info
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isAppear = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isAppear = false
                    }
                }
            }
    }
}

private struct SnackBarView: View {
    
    let info: SnackBarInfo
        
    var body: some View {
        HStack {
            if let image = info.image {
                image
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
            }
            
            Text(info.message)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).fill(info.backgroundColor))
        .padding(.horizontal)
    }
}

// MARK: - Extensions

public extension NotificationCenter {
    static func snackBarNotif(info: SnackBarInfo) {
        NotificationCenter.default.post(name: .init("LCTool.SnackBarInfoViewModifier"), object: info)
    }
}

public extension View {
    func snackBarCenter() -> some View {
        modifier(SnackBarInfoViewModifier())
    }
}

// MARK: - Preview

struct SnackBarPreview: View {
        
    let info = SnackBarInfo(message: "Bonjour je suis un dracofeu, j'aime les tomates et je crache du feu",
                                 image: nil,
                                 backgroundColor: .red)
    let info2 = SnackBarInfo(message: "Bonjour je suis un Florizarre, j'aime les salade et fouette les arabes",
                                  image: .init(systemName: "doc"),
                                 backgroundColor: .green)
    let info3 = SnackBarInfo(message: "Bonjour je suis un Tortank, j'aime les raisins et j'arose!",
                                 image: nil,
                                 backgroundColor: .blue)
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .ignoresSafeArea()
            actionButton
        }
        .snackBarCenter()
    }
    
    var actionButton: some View {
        Button(action: {
            NotificationCenter.snackBarNotif(info: [info, info2, info3].randomElement()!)
        }, label: {
            Text("try me")
        })
    }
}

#Preview {
    SnackBarPreview()
}
