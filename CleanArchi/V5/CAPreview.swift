//
//  CAPreviewProtocol.swift
//  Mon Compte Free
//
//  Created by Free on 16/11/2023.
//

import Foundation
import SwiftUI

protocol CAPreviewProtocol {
    var config: [CAUsecaseOption] { get set }
    var keys: [CAPreviewKey] {get}
    var label: String {get}
    func inject(key: String?)
}

extension CAPreviewProtocol {
    var config: [CAUsecaseOption] { get {[]} set {}}
    
    var label: String {
        String(describing: Self.Type.self).replacingOccurrences(of: "Preview.Type", with: "")
    }
}

struct CAPreviewKey: Identifiable {
    let label: String
    let key: String
    
    var id: String { key }
}

extension View {
    func inject(preview: CAPreviewProtocol, task: (() -> Void)? = nil) -> some View {
        preview.inject(key: nil)
        return self.task {
            task?()
        }
    }
}

func debug(_ str: String) {
    if ProcessInfo.processInfo.arguments.contains("-verbose") {
        print(str)
    }
}
