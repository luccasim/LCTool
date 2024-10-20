//
//  TestStatusCodeView.swift
//  Integration
//
//  Created by Free on 22/09/2024.
//

import SwiftUI

struct TestStatusCodeView: View {
    
    @State private var error: [String: Any]?
    @State private var isPresented: Bool = false
    
    let getAnanasUsecase = GetAnanasUsecase()
    let codes = [200, 400, 401, 403, 404, 500, 69]
    
    var body: some View {
        VStack(spacing: 20) {
            
            ForEach(codes, id: \.self) { code in
                Button("Test \(code)") {
                    test(code: code)
                }
            }
            
            Divider()
            
            VStack {
                if let originalError = error?["error"] as? Error, let businessError = error?["businessError"] as? Error{
                    VStack {
                        Group {
                            Text("__Service Error:__ ") + Text(originalError.localizedDescription)
                            Text("__Business Error:__ ") + Text(businessError.localizedDescription)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.publisher(id: "loggerService")) { ouput in
            DispatchQueue.main.async {
                if let value = ouput.object as? (String, [String: Any]) {
                    self.error = value.1
                }
            }
        }
    }
    
    func test(code: Int) {
        self.error = nil
        Task {
            do {
                try await getAnanasUsecase.bipbip(input: .init(id: code))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    TestStatusCodeView()
}
