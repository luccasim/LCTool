//
//  SnackBarView.swift
//  TestV6
//
//  Created by Free on 05/06/2024.
//

import SwiftUI
import Combine

public struct SnackBarInfo {
    
    public init(message: String) {
        self.message = message
        self.image = nil
        self.backgroundColor = .gray
        self.displayTime = 5
        self.haptic = nil
    }
    
    public init(message: String,
                image: Image? = nil,
                backgroundColor: Color = .gray,
                displayTime: Double = 5,
                haptic: UIImpactFeedbackGenerator.FeedbackStyle? = nil) {
        self.message = message
        self.image = image
        self.backgroundColor = backgroundColor
        self.displayTime = displayTime
        self.haptic = haptic
    }
    
    let message: String
    let image: Image?
    let backgroundColor: Color
    let displayTime: Double
    let haptic: UIImpactFeedbackGenerator.FeedbackStyle?
    
    public enum Position {
        case top, bottom
    }
}

// MARK: - Extensions

public extension NotificationCenter {
    static func snackBarNotif(info: SnackBarInfo) {
        NotificationCenter.default.post(name: .init("LCTool.SnackBarInfoViewModifier"), object: info)
    }
}

public extension View {
    func snackBarCenter(position: SnackBarInfo.Position = .bottom) -> some View {
        modifier(SnackBarInfoViewModifier(position: position))
    }
}

// MARK: - Views

private class SnackBarVM: ObservableObject {
    
    @Published var info: SnackBarInfo = .init(message: "", image: nil)
    @Published var isAppear = false
    
    let subject = PassthroughSubject<SnackBarInfo, Never>()
    var cancellable: AnyCancellable?
    
    init() {
         cancellable = subject
            .throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true)
            .sink { info in
                self.update(info: info)
            }
    }
    
    func add(info: SnackBarInfo) {
        subject.send(info)
    }
    
    private func update(info: SnackBarInfo) {
        self.info = info
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isAppear = true
            if let haptic = info.haptic {
                UIImpactFeedbackGenerator(style: haptic).impactOccurred()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + info.displayTime) {
            self.isAppear = false
        }
    }
}

private struct SnackBarInfoViewModifier: ViewModifier {
    
    @StateObject private var viewModel = SnackBarVM()
    let position: SnackBarInfo.Position
    
    var offset: CGFloat {
        viewModel.isAppear ?
        position == .bottom ? -10 : 0 :
        position == .bottom ? 100 : -130
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            content
        }
        .overlay(alignment: position == .bottom ? .bottom : .top) {
            SnackBarView(info: viewModel.info)
                .offset(y: offset)
                .animation(.spring, value: offset)
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("LCTool.SnackBarInfoViewModifier"))) { output in
            if let info = output.object as? SnackBarInfo {
                viewModel.add(info: info)
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(info.backgroundColor)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
        .padding(.horizontal, 24)
    }
}


// MARK: - Preview

struct SnackBarPreview: View {
    
    @State private var isPresentedSheet = false
        
    let info = SnackBarInfo(message: "J'aime les tomates",
                            backgroundColor: .red,
                            displayTime: 2)
    let info2 = SnackBarInfo(message: "J'aime les salade",
                             image: .init(systemName: "doc"),
                             backgroundColor: .green)
    let info3 = SnackBarInfo(message: "J'aime les raisins!",
                             backgroundColor: .blue)
    
    var body: some View {
        actionButton
            .snackBarCenter()
    }
    
    var actionButton: some View {
        ZStack {
            SnackBarView(info: .init(message: "Test"))
                .offset(x: 20, y: -20)
                .opacity(0.8)
            SnackBarView(info: .init(message: "Test"))
                .offset(x: 10, y: -10)
                .opacity(0.9)
            SnackBarView(info: .init(message: "Test"))
        }
    }
}

#Preview {
    SnackBarPreview()
}
