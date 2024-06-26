//
//  URLRequest+Extension.swift
//  TestV6
//
//  Created by Free on 03/06/2024.
//

import Foundation

public extension URLRequest {
    
    enum HTTPMethod: String {
        case get, put, post, delete
    }
    
    enum BodyForm {
        case raw(json: Codable?)
        case urlEncoded([String: String]?)
        case multiform([(key: String, url: URL)])
    }
    
    init?(path: String,
          queries: [String: String] = [:],
          httpMethod: HTTPMethod = .get,
          header: [String: String] = [:],
          bodyForm: BodyForm? = .none
    ) {
                
        guard var components = URLComponents(string: path) else {
            return nil
        }
        
        if !queries.isEmpty {
            components.queryItems = queries.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = components.url else {
            return nil
        }

        self.init(url: url)
        self.httpMethod = httpMethod.rawValue.uppercased()
        self.allHTTPHeaderFields = header
        
        self.timeoutInterval = 20

        guard httpMethod == .post else {
            return
        }
        
        var httpHeader = header
        
        switch bodyForm {
        case .multiform(let data):
            let fileForm = MultiFormData(files: data)
            httpHeader["Content-Type"] = fileForm.toContentType
            self.allHTTPHeaderFields = httpHeader
            self.httpBody = fileForm.toBody
            self.timeoutInterval = 30
        case .raw(json: let codable):
            httpHeader["Content-Type"] = "application/json"
            self.allHTTPHeaderFields = httpHeader
            self.httpBody = codable.flatMap({try? JSONEncoder().encode($0)})
        case .urlEncoded(let data):
            httpHeader["Content-Type"] = "application/x-www-form-urlencoded"
            self.allHTTPHeaderFields = httpHeader
            self.httpBody = data?.reduce("") { partialResult, dict in
                "\(dict.key)=\(dict.value)&\(partialResult)"
            }
            .dropLast()
            .description
            .data(using: .utf8)
        default:
            break
        }
    }
    
    var toCURL: String {
        guard let url = self.url else { return "" }
        
        var command = "curl -X \(self.httpMethod ?? "GET") '\(url.absoluteString)'"
        
        if let headers = self.allHTTPHeaderFields {
            for (key, value) in headers {
                command += " -H '\(key): \(value)'"
            }
        }
        
        if let httpBody = self.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            command += " -d '\(bodyString)'"
        }
        
        return command
    }
}

// MARK: MultiFormData

private struct MultiFormData {
    
    let files: [(key: String, url: URL)]
    private let boundary = "Boundary-\(UUID().uuidString)"
    
    var toContentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    var toBody: Data? {
        let medias = self.files.compactMap({Media(url: $0.url, key: $0.key)})
        return createData(params: nil, media: medias, boundary: boundary)
    }
    
    struct Media {
        
        let key: String
        let fileName: String
        let mimeType: String
        let data: Data
        
        init?(url: URL, key: String) {
            self.key = key
            do {
                data = try Data(contentsOf: url)
            } catch {
                return nil
            }
            
            switch url.pathExtension {
            case "jpeg", "png", "gif", "pdf":
                mimeType = "image/\(url.pathExtension)"
            default:
                mimeType = ""
            }
            
            fileName = url.lastPathComponent
        }
    }
    
    fileprivate func createData(params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let params = params {
            for (key, value) in params {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for elem in media {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(elem.key)\"; filename=\"\(elem.fileName)\"\r\n")
                body.append("Content-Type: \(elem.mimeType)\r\n\r\n")
                body.append(elem.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

fileprivate extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    var toPrettyJSON: NSString {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                     options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return NSString(string: "#NotJSON")
        }
        
        return prettyJSON
    }
}
