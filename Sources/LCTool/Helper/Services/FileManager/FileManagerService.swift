//
//  FileManagerService.swift
//  Mon Compte Free
//
//  Created by Free on 09/09/2024.
//

import Foundation
import UIKit

public final class FileManagerService {
    
    func checkFileExistance(directory: FileManager.SearchPathDirectory, fileName: String, path: String) -> Bool {
        guard let documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return false
        }
        
        let path = documentsUrl.appendingPathComponent(path).appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: path)
    }
    
    func isDirectoryEmpty(directory: FileManager.SearchPathDirectory, path: String?) -> Bool {
        directoryContent(directory: directory, path: path).isEmpty
    }
    
    func directoryContent(directory: FileManager.SearchPathDirectory, path: String?) -> [String] {
        guard var documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return []
        }
        
        if let additionalPath = path {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsUrl.path)
            return files
        } catch {
            return []
        }
    }
    
    func deleteDirectory(directory: FileManager.SearchPathDirectory, path: String?) {
        guard var documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        
        if let additionalPath = path {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }
        
        if FileManager.default.fileExists(atPath: documentsUrl.path) {
            do {
            try FileManager.default.removeItem(at: documentsUrl)
                print("[Success] Delete documentDirectory")
            } catch {
                print("[Failed] Delete documentDirectory")
            }
        }
    }
    
    func openFile(directory: FileManager.SearchPathDirectory, path: String?) {
        guard var documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        
        if let additionalPath = path?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }

        if let sharedUrl = URL(string: "shareddocuments://\(documentsUrl.path)") {
            if UIApplication.shared.canOpenURL(sharedUrl) {
                UIApplication.shared.open(sharedUrl, options: [:])
            }
        }
    }
    
    func removeFile(directory: FileManager.SearchPathDirectory, fileName: String, path: String?) {
        guard var documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        
        if let additionalPath = path?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }
        
        documentsUrl = documentsUrl.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: documentsUrl.path) {
            do {
            try FileManager.default.removeItem(at: documentsUrl)
                print("[Success] Delete documentDirectory")
            } catch {
                print("[Failed] Delete documentDirectory")
            }
        }
    }
    
    func saveFile(directory: FileManager.SearchPathDirectory, data: Data, fileName: String, path: String) {
        guard let documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first?
            .appendingPathComponent(path) else {
            return
        }
        
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        
        do {
            
            if !FileManager.default.fileExists(atPath: documentsUrl.path) {
                try FileManager.default.createDirectory(at: documentsUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
}