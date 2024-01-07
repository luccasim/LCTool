//
//  MockView.swift
//  Mon Compte Free
//
//  Created by Free on 05/07/2023.
//

import SwiftUI

struct MockView: View {
    
    @State private var selection = "Normal"
    
    let mock: CAMockProtocol
    
    var body: some View {
        Section {
            Picker(selection: $selection) {
                ForEach(mock.keys, id: \.self) { key in
                    Text(key)
                }
            } label: {
                Text(mock.description.replacingOccurrences(of: "Fbx", with: ""))
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .onChange(of: selection) { newValue in
                mock.inject(key: newValue)
            }
            .onAppear {
                if let selected = UserDefaults.standard.string(forKey: mock.description) {
                    selection = selected
                }
            }
        }
    }
}

extension View {
    
    func previewInject(mock: CAMockProtocol) -> some View {
        mock.preview()
        return self
    }
    
    func previewMock(allCases: CAMockProtocol) -> some View {
        Group {
            ForEach(allCases.keys, id: \.self) { key in
                self.previewDisplayName(key).onAppear {
                    allCases.inject(key: key)
                }
            }
        }
    }
}
