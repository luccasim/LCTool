//
//  WriteFileManager.swift
//  Mon Compte Free
//
//  Created by Free on 06/10/2021.
//

import Foundation
import UniformTypeIdentifiers

protocol WriteFileManagerProtocol {
    var directory: FileManager.SearchPathDirectory {get set}
    var directoryName: String {get set}
    func read(fileName: String) -> Data?
    func write(fileName: String, source: URL)
    func write(fileName: String, data: Data)
}

protocol WriteCodableProtocol {
    func write<T: Codable>(codableFileName: String, codableData: T)
    func read<T: Codable>(codableFileName: String) -> T?
    func delete(fileName: String)
}

protocol WriteTMPFileProtocol {
    func write(tmpData: Data, fileExtension: UTType) -> URL?
    func removeTmpDirectory()
}

final class WriteFileManager: WriteFileManagerProtocol {
    
    var directory = FileManager.SearchPathDirectory.cachesDirectory
    var directoryName = "local"
    
    private var documentFileURL: URL {
        FileManager.default
            .urls(for: directory, in: .userDomainMask)[0]
            .appendingPathComponent(directoryName)
    }
    
    func read(fileName: String) -> Data? {
        let fileURL = documentFileURL.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }
    
    func write(fileName: String, source: URL) {
        
        let fileURL = documentFileURL.appendingPathComponent(fileName)
        
        do {
            
            if !FileManager.default.fileExists(atPath: documentFileURL.path) {
                try FileManager.default.createDirectory(atPath: documentFileURL.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            try FileManager.default.copyItem(at: source, to: fileURL)
            
        } catch let error {
            #if DEBUG
            print("write() error => \(error.localizedDescription)")
            #endif
        }
    }
    
    func write(fileName: String, data: Data) {
        
        let fileURL = documentFileURL.appendingPathComponent(fileName)
        
        do {
            
            if !FileManager.default.fileExists(atPath: documentFileURL.path) {
                try FileManager.default.createDirectory(at: documentFileURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            
            try data.write(to: fileURL)
            
        } catch let error {
            #if DEBUG
            print("write() error => \(error.localizedDescription)")
            #endif
        }
    }
    
    func delete(fileName: String) {
        let fileURL = documentFileURL.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: fileURL)
    }
}

extension WriteFileManager: WriteCodableProtocol {
    
    func write<T: Codable>(codableFileName: String, codableData: T) {
        if let data = try? JSONEncoder().encode(codableData) {
            self.write(fileName: codableFileName, data: data)
        }
    }
    
    func read<T: Codable>(codableFileName: String) -> T? {
        if let data = self.read(fileName: codableFileName) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
}

extension WriteFileManager: WriteTMPFileProtocol {
    
    var tmpDirectory: URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("local")
            .appendingPathComponent("tmp")
    }
    
    func write(tmpData: Data, fileExtension: UTType = .jpeg) -> URL? {
        
        let tmpFileNumber = UserDefaults.standard.integer(forKey: "tmpFile")
        let fileURL = tmpDirectory.appendingPathComponent(tmpFileNumber.description)
            .appendingPathExtension(for: fileExtension)
        
        do {
            
            if !FileManager.default.fileExists(atPath: tmpDirectory.path) {
                try FileManager.default.createDirectory(at: tmpDirectory,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            
            try tmpData.write(to: fileURL)
            UserDefaults.standard.set(tmpFileNumber + 1, forKey: "tmpFile")
            return fileURL
            
        } catch let error {
            #if DEBUG
            print("write() error => \(error.localizedDescription)")
            #endif
            return nil
        }
    }
    
    func removeTmpDirectory() {
        let dirURL = tmpDirectory
        
        do {
            try FileManager.default.removeItem(at: dirURL)
            UserDefaults.standard.set(0, forKey: "tmpFile")
        } catch {
            
        }
    }
}
