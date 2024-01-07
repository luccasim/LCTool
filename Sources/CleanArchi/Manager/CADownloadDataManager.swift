//
//  CADownloadDataManager.swift
//  Mon Compte Free
//
//  Created by Free on 09/08/2023.
//

import Foundation

// MARK: - CADownloadDataManager

protocol CADownloadDataManagerProtocol {
    func retrieveData(url: URL?) -> Data?
    func fetchData(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
    func fetchData(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
    func load(requests: [URLRequest], completion: @escaping (() -> Void))
}

final class CADownloadDataManager {
        
    // Dependencies
    private var writeManager: WriteCodableProtocol & WriteFileManagerProtocol
    private var webServiceManager: CAWebserviceProtocol
    private var cacheManager: CACacheProtocol
    
    private var registerDictonary = [String: String]()
    
    init(webServiceManager: CAWebserviceProtocol = CAWebserviceManager.shared,
         writeManager: WriteCodableProtocol & WriteFileManagerProtocol = WriteFileManager(),
         cacheManager: CACacheProtocol = CACacheManager()) {
        self.writeManager = writeManager
        self.webServiceManager = webServiceManager
        self.cacheManager = cacheManager
        self.loadCache()
    }
    
    private func loadCache() {
        if let dict = UserDefaults.standard.object(forKey: "CADownloadDataManager") as? [String: String] {
            dict.forEach {
                if let data = self.writeManager.read(fileName: $0.key) {
                    self.cacheManager[$0.value, 300] = data
                }
            }
            self.registerDictonary = dict
        }
    }
    
    private func addOnCache(fileName: String, uri: String, fileData: Data) {
        self.cacheManager[uri, 300] = fileData
        self.registerDictonary[fileName] = uri
        UserDefaults.standard.set(self.registerDictonary, forKey: "CADownloadDataManager")
    }
    
    private func check(request: URLRequest, storedData: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let storedData = storedData else {
            return self.download(request: request, storedData: storedData, completion: completion)
        }
        
        var headRequest = request
        headRequest.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            
            // Fail if expected length count is equals to storedData count
            if let dataLength = response?.expectedContentLength, dataLength == storedData.count {
                return completion(.failure(Failure.notUpdated))
            }
            
            // Else download
            self.download(request: request, storedData: storedData, completion: completion)
        }
        .resume()
    }
    
    private func download(request: URLRequest, storedData: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let fileName = request.url?.lastPathComponent else {
            return completion(.failure(Failure.unableGetFileName))
        }
        
        var downloadRequest = request
        downloadRequest.caAddServiceDescription(desc: "Download \(fileName)")
        
        self.webServiceManager.downloadTask(request: request) { result in
            
            switch result {
            case .success(let tmp):
                
                // Write on document directory
                self.writeManager.write(fileName: fileName, source: tmp)
                
                // Get the fileData
                guard let fileData = self.writeManager.read(fileName: fileName),
                        let requestURL = request.url?.absoluteString else {
                    return completion(.failure(Failure.writeManagerError))
                }
                
                // set on cache and register the url on the register image table.
                self.addOnCache(fileName: fileName, uri: requestURL, fileData: fileData)
                
                return completion(.success(fileData))
                
            case .failure(let failure):
                return completion(.failure(failure))
            }
        }
    }
}

extension CADownloadDataManager: CADownloadDataManagerProtocol {
    
    static let shared = CADownloadDataManager()
    
    enum Failure: Error {
        case writeManagerError
        case unableToCreateKey
        case notUpdated
        case unableGetFileName
    }
    
    func retrieveData(url: URL?) -> Data? {
        guard let url = url?.absoluteString else { return nil }
        return cacheManager[url] as? Data
    }

    func fetchData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        self.fetchData(request: request, completion: completion)
    }
    
    func fetchData(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        var storedData: Data?
                
        if let data = cacheManager[request.url?.absoluteString ?? ""] as? Data {
            storedData = data
        }
        
        self.check(request: request, storedData: storedData, completion: completion)
    }
    
    func load(requests: [URLRequest], completion: @escaping (() -> Void)) {
        let group = DispatchGroup()
        
        requests.forEach { request in
            group.enter()
            check(request: request, storedData: nil) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
