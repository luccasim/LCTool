//___FILEHEADER___
//  Template: 6.0

import Foundation
import LCTool

struct ___VARIABLE_ModuleName:identifier___Endpoint: Codable {
    
    // MARK: - Params
    
    var httpHeader: [String: String] = [:]
    
    // MARK: - Request
        
    var request: URLRequest? {
        // Header
        var header: [String: String] = httpHeader

        // HttpMethod
        let method: URLRequest.HTTPMethod = .post

        // Queries
        let queries: [String: String] = [:]
        
        // Endpoint
        let url = ""
        
        // Body
        var body: URLRequest.BodyForm?
        
        // Json
//        let bodyRequest = ___VARIABLE_ModuleName:identifier___Body()
//        body = .raw(json: bodyRequest)
        
        // Encoded
//        let values: [String: String]? = nil
//        body = .urlEncoded(values)
        
        // MultiForm
//        let files: [URL]? = nil
//        let media = files?.compactMap({("file", $0)}) ?? []
//        body = .multiform(media)
        
        // Description
        header["ServiceLabel"] = "___VARIABLE_ModuleName:identifier___"
        
        // URLRequest
        return URLRequest(path: url, queries: queries, httpMethod: method, header: header, bodyForm: body)
    }
}
