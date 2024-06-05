//
//  File.swift
//  
//
//  Created by Luc on 15/01/2024.
//

import SwiftUI
import Combine

// MARK: - Model

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
    
    public enum Style {
        case one, stack
    }
}

// MARK: - Extensions

public extension NotificationCenter {
    static func snackBarNotif(info: SnackBarInfo) {
        NotificationCenter.default.post(name: .init("LCTool.SnackBarInfoViewModifier"), object: info)
    }
}

public extension View {
    func snackBarCenter(position: SnackBarInfo.Position = .bottom, 
                        style: SnackBarInfo.Style = .one) -> some View {
        modifier(SnackBarInfoViewModifier(position: position, style: style))
    }
}

// MARK: - ViewModel

private class SnackBarVM: ObservableObject {
    
    @Published var info: SnackBarInfo = .init(message: "", image: nil)
    @Published var infos = [OrderedSnackInfo]()
    @Published var isAppear = false
    @Published var isPresentedDetail = false

    private var timer: Timer?
    
    struct OrderedSnackInfo: Identifiable {
        var id: Int
        var info: SnackBarInfo
    }
    
    var recentInfo: [OrderedSnackInfo] {
        infos.suffix(3)
    }
    
    func add(info: SnackBarInfo) {
        update(info: info)
        if !isPresentedDetail {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: info.displayTime, repeats: false, block: { timer in
                self.clearToast()
            })
        }
    }
    
    private func clearToast() {
        self.isAppear = false
        self.infos = []
        self.isPresentedDetail = false
    }
    
    func openToasts() {
        timer?.invalidate()
        self.isPresentedDetail = true
    }
    
    func closeToasts() {
        self.clearToast()
    }
    
    private func update(info: SnackBarInfo) {
        infos.append(.init(id: infos.count, info: info))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isAppear = true
            if let haptic = info.haptic {
                UIImpactFeedbackGenerator(style: haptic).impactOccurred()
            }
        }
    }
}

// MARK: - ViewModifier

private struct SnackBarInfoViewModifier: ViewModifier {
    
    @StateObject private var viewModel = SnackBarVM()
    
    let position: SnackBarInfo.Position
    let style: SnackBarInfo.Style
    
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
            snackBarContent
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("LCTool.SnackBarInfoViewModifier"))) { output in
            if let info = output.object as? SnackBarInfo {
                viewModel.add(info: info)
            }
        }
    }
    
    @ViewBuilder
    private var snackBarContent: some View {
        switch style {
        case .one:
            SnackBarView(info: viewModel.info)
                .offset(y: offset)
                .animation(.spring, value: offset)
        case .stack:
            SnackBarStack(viewModel: viewModel, position: position)
                .offset(y: offset)
                .animation(.spring, value: offset)
        }
    }
}

// MARK: - Views

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
                .opacity(0.9)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
        .padding(.horizontal, 24)
    }
}

private struct SnackBarStack: View {
    
    @ObservedObject var viewModel: SnackBarVM
    let position: SnackBarInfo.Position
    
    var body: some View {
        ZStack {
            if viewModel.isPresentedDetail {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.closeToasts()
                        } label: {
                            Circle()
                                .foregroundStyle(Color.gray.opacity(0.5))
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(Color.black)
                                        .frame(width: 10, height: 10)
                                }
                                .padding(.trailing, 24)
                        }
                    }
                    if viewModel.infos.count < 7 {
                        ForEach(viewModel.infos) { snackInfo in
                            SnackBarView(info: snackInfo.info)
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(viewModel.infos) { snackInfo in
                                    SnackBarView(info: snackInfo.info)
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.width)
                    }
                }
            } else {
                ForEach(viewModel.recentInfo) { snackInfo in
                    SnackBarView(info: snackInfo.info)
                        .offset(x: CGFloat((viewModel.infos.count - 1 - snackInfo.id) * 10),
                                y: CGFloat((viewModel.infos.count - 1 - snackInfo.id) * -10))
                        .animation(.easeInOut, value: snackInfo.id)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isPresentedDetail)
        .onTapGesture {
            viewModel.openToasts()
        }
    }
}

// MARK: - Preview

struct SnackBarPreview: View {
    
    @State private var isPresentedSheet = false
        
    let info = SnackBarInfo(message: "J'aime les tomates",
                            backgroundColor: .red,
                            displayTime: 60)
    let info2 = SnackBarInfo(message: "J'aime les salade",
                             image: .init(systemName: "doc"),
                             backgroundColor: .green)
    let info3 = SnackBarInfo(message: "J'aime les raisins!")
    
    var body: some View {
        actionButton
            .snackBarCenter(position: .bottom, style: .stack)
    }
    
    var actionButton: some View {
        Button(action: {
            NotificationCenter.snackBarNotif(info: [info, info2, info3].randomElement()!)
        }, label: {
            Text("Send Toast")
        })
    }
}

#Preview {
    SnackBarPreview()
}
