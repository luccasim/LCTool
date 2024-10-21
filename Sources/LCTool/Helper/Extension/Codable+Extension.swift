//
//  Decodable+Extension.swift
//  TestV6
//
//  Created by Free on 30/05/2024.
//

import Foundation

extension Decodable {
    
    /// add the complete filename with file extension i.e example.json
    public static func readPreviewFile(fileName: String) -> Self! {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(Self.self, from: data)
            } catch {
                return nil
            }
        }
        return nil
    }
}

extension Encodable {
    
    public var prettyJSON: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Erreur lors de l'encodage JSON : \(error)")
        }

        return nil
    }
}
