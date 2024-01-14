//
//  CAPreviewPickerView.swift
//  Mon Compte Free
//
//  Created by Free on 06/11/2023.
//

import SwiftUI

struct CAPreviewPickerView: View {
    
    @State private var selection = "prod"
    
    let preview: CAPreviewProtocol
    
    var body: some View {
        Section {
            Picker(selection: $selection) {
                ForEach(preview.keys) { key in
                    Text(key.label)
                }
            } label: {
                Text(preview.label)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .onChange(of: selection) { newValue in
                if let key = preview.keys.first(where: {$0.label == selection})?.key {
                    preview.inject(key: key)
                    UserDefaults.standard.setValue(newValue, forKey: preview.label)
                }
            }
            .onAppear {
                if let selected = UserDefaults.standard.string(forKey: preview.label) {
                    selection = selected
                    if let key = preview.keys.first(where: {$0.label == selection})?.key {
                        preview.inject(key: key)
                    }
                }
            }
        }
    }
}
