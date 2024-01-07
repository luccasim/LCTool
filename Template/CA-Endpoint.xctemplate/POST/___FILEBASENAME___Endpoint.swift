//___FILEHEADER___
//  Template: 5.0

import Foundation

// MARK: - Endpoint

struct ___VARIABLE_ModuleName:identifier___Endpoint: Codable {
    var httpHeader: [String: String] = [:]
}

extension ___VARIABLE_ModuleName:identifier___Endpoint: CAEndpointProtocol {
    
    typealias T = ___VARIABLE_ModuleName:identifier___Response
    
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
