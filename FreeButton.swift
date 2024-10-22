//
//  FreeButton.swift
//  Integration
//
//  Created by Mattéo Fauchon  on 27/10/2023.
//

import SwiftUI

struct FreeButton: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    enum ButtonRole {
        case normal, destructive
    }
    
    enum ButtonType {
        case primary, secondary, action(image: Image? = nil, role: ButtonRole), option(isSelected: Bool = false)
    }
    
    var type: ButtonType
    var label: LocalizedStringKey
    var isLoading: Bool
    var action: () -> Void
    
    init(type: ButtonType, label: LocalizedStringKey, isLoading: Bool = false, action: @escaping () -> Void) {
        self.type = type
        self.label = label
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        switch type {
        case .primary:
            primary
        case .secondary:
            secondary
        case .action(let image, let role):
            action(image, role: role)
        case .option(let isSelected):
            option(isSelected)
        }
    }
    
    private var primary: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(label)
                    .opacity(isLoading ? 0 : 1)
                LoadingView(lottie: .loaderWhite)
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .animation(.easeInOut, value: isLoading)
        .buttonStyle(PrimaryButtonStyle())
    }
    
    private var secondary: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(label)
                    .opacity(isLoading ? 0 : 1)
                if colorScheme == .light {
                    LoadingView(lottie: .loaderBlack)
                        .opacity(isLoading ? 1 : 0)
                } else {
                    LoadingView(lottie: .loaderWhite)
                        .opacity(isLoading ? 1 : 0)
                }
            }
        }
        .animation(.easeInOut, value: isLoading)
        .buttonStyle(SecondaryButtonStyle())
    }
    
    private func action(_ image: Image? = nil, role: ButtonRole) -> some View {
        Button {
            action()
        } label: {
            HStack {
                if let image = image {
                    image
                        .renderingMode(.template)
                }
                Text(label)
            }
            .opacity(!isLoading ? 1 : 0)
            .overlay {
                VStack {
                    if role == .destructive {
                        LoadingView(lottie: .loaderRed)
                    } else if colorScheme == .light {
                        LoadingView(lottie: .loaderBlack)
                    } else {
                        LoadingView(lottie: .loaderWhite)
                    }
                }.opacity(isLoading ? 1 : 0)
            }
        }
        .animation(.easeInOut, value: isLoading)
        .buttonStyle(ActionButtonStyle(role: role))
    }
    
    private func option(_ isSelected: Bool = false) -> some View {
        Button {
            action()
        } label: {
            Text(label)
        }
        .buttonStyle(OptionButtonStyle(isSelected: isSelected))
    }
}

// MARK: - Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .freeText(font: .bodyS2, color: isEnabled ? .white : .gray500)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: .big)
            .background(backgroundColor(config: configuration))
            .clipShape(Capsule())
            .padding(.horizontal, .tiny)
    }
    
    private func backgroundColor(config: Configuration) -> Color {
        return if !isEnabled {
            Color.gray100
        } else if config.isPressed {
            Color.red700
        } else {
            Color.alwaysRed500
        }
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .freeText(font: .bodyS2, color: isEnabled ? .gray800 : .gray300)
            .frame(maxWidth: .infinity)
            .frame(height: .big)
    }
}

private struct ActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var role: FreeButton.ButtonRole
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .freeText(font: .bodyS2, color: foregroundColor)
            .padding(.horizontal, .medium)
            .padding(.vertical, .tiny)
            .frame(height: .big)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(strokeColor)
            )
    }
    
    private var backgroundColor: Color {
        return if role == .normal && !isEnabled {
            .gray50
        } else {
            .clear
        }
    }
    
    private var strokeColor: Color {
        return if role == .normal {
            colorScheme == .light || !isEnabled ? .gray100 : .gray800
        } else {
            isEnabled ? .redCore : .gray100
        }
    }
    
    private var foregroundColor: Color {
        return if role == .normal {
            isEnabled ? .gray600 : .gray300
        } else {
            isEnabled ? .redCore : .gray300
        }
    }
}

private struct OptionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .freeText(font: .bodyS2, color: foregroundColor, alignment: .center)
            .padding(.horizontal, .small)
            .frame(maxWidth: .infinity)
            .frame(height: .big)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .tiny))
            .overlay(
                RoundedRectangle(cornerRadius: .tiny)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .padding(.horizontal, .tiny)
    }
    
    private var foregroundColor: Color {
        return if isSelected {
            .gray100
        } else {
            .gray900
        }
    }
    
    private var backgroundColor: Color {
        return if isSelected {
            .semanticInformationText
        } else if colorScheme == .light {
            .white
        } else {
            .gray100
        }
    }
    
    private var strokeColor: Color {
        return if isSelected {
            .semanticInformationText
        } else {
            .gray200
        }
    }
}

#Preview {
    FreeButton(type: .primary, label: "") {}
}
