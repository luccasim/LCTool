//___FILEHEADER___
//  Template: 6.0

import Foundation
import LCTool

@Endpoint
struct ___VARIABLE_ModuleName:identifier___Endpoint: Codable {
    
    // MARK: - Params
    
    var httpHeader: [String: String] = [:]
    
    // MARK: - Request
    
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
        return URLRequest(path: url, queries: queries, httpMethod: method, header: header, bodyForm: nil)
    }
}
