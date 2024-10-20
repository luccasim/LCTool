//___FILEHEADER___
//  Template: 7.0

import Foundation

struct ___VARIABLE_ModuleName:identifier___Endpoint: Codable {
    let httpHeader: [String: String]
}
    
extension ___VARIABLE_ModuleName:identifier___Endpoint: URLSessionServiceEndpoint {
    
    typealias Response = ___VARIABLE_ModuleName:identifier___Response
    
    var request: URLRequest? {
        // Header
        var header: [String: String] = httpHeader

        // HttpMethod
        let method: URLRequest.HTTPMethod = .get

        // Queries
        let queries: [String: String] = [:]
        
        // Endpoint
        let url = ""
        
        // Description
        header["ServiceLabel"] = "___VARIABLE_ModuleName:identifier___"
        
        // URLRequest
        return URLRequest(path: url, queries: queries, httpMethod: method, header: header)
    }
}
