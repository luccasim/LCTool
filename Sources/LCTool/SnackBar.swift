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
    
    public init<T: View>(
        style: Style = .stack,
        backgroundColor: Color? = .gray,
        showTime: Double = 5,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = nil,
        @ViewBuilder content: () -> T
    ) {
        self.content = AnyView(content())
        self.displayTime = showTime
        self.backgroundColor = backgroundColor
        self.haptic = haptic
        self.message = nil
        self.image = nil
        self.style = style
    }
    
    public init(
        style: Style = .stack,
        message: String,
        image: Image? = nil,
        backgroundColor: Color? = .gray,
        showTime: Double = 5,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = nil
    ) {
        self.message = message
        self.image = image
        self.backgroundColor = backgroundColor
        self.displayTime = showTime
        self.haptic = haptic
        self.content = nil
        self.style = style
    }
    
    let content: AnyView?
    let message: String?
    let image: Image?
    let backgroundColor: Color?
    let displayTime: Double
    let haptic: UIImpactFeedbackGenerator.FeedbackStyle?
    let style: Style
    
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
    
    @Published var infos = [OrderedSnackInfo]()
    @Published var incommingValue: OrderedSnackInfo?
    
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
        self.incommingValue = nil
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
        let new = OrderedSnackInfo(id: infos.count, info: info)
        incommingValue = new
        if new.info.style == .stack {
            infos.append(new)
        }
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
            stackView
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("LCTool.SnackBarInfoViewModifier"))) { output in
            if let info = output.object as? SnackBarInfo {
                viewModel.add(info: info)
            }
        }
    }
    
    @ViewBuilder
    private var bannerView: some View { // transition
        if let new = viewModel.incommingValue, new.info.style == .one {
            SnackBarView(info: new.info)
                .transition(.move(edge: .bottom))
                .animation(.easeIn(duration: 0.5), value: new.id)
        }
    }
    
    @ViewBuilder
    private var stackView: some View { // sans transition
        if let new = viewModel.incommingValue, viewModel.isAppear {
           SnackBarStack(viewModel: viewModel, position: position)
        }
    }
}

// MARK: - Views

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
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(Color.black)
                                        .frame(width: 8, height: 8)
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

private struct SnackBarView: View {
    
    let info: SnackBarInfo?
        
    var body: some View {
        if let info = info {
            if let backgroundColor = info.backgroundColor {
                content
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                            .opacity(0.9)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
                    .padding(.horizontal, 24)
            } else {
                content
            }
        } else {
            Color.orange.frame(width: 1, height: 1)
        }
    }
    
    private var content: some View {
        Group {
            if let anyView = info?.content {
                anyView
            } else if let message = info?.message {
                HStack {
                    if let image = info?.image {
                        image
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 12, height: 12)
                    }
                    
                    Text(message)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

struct SnackBarPreview: View {
    
    @State private var isPresentedSheet = false
        
    let info = SnackBarInfo(style: .one, backgroundColor: .green) {
        Text("Hello!!")
            .font(.callout)
            .foregroundStyle(Color.white)
            .multilineTextAlignment(.leading)
    }
    
    let info2 = SnackBarInfo(message: "Bonjour")
    
    let info3 = SnackBarInfo(backgroundColor: nil) {
        VStack {
            HStack {
                Image(systemName: "pencil.line")
                Text("Sans background")
                Spacer()
            }
            Text("Second Element")
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        actionButton
            .snackBarCenter(position: .bottom, style: .stack)
    }
    
    var actionButton: some View {
        Button(action: {
            NotificationCenter.snackBarNotif(info: [info, info2, info3].randomElement()!)
        }, label: {
            Text("Send")
        })
    }
}

#Preview {
    SnackBarPreview()
}
