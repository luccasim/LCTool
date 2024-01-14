//
//  AppFilesManager.swift
//  Mon Compte Free
//
//  Created by Free on 19/07/2023.
//

import Foundation
import SwiftUI

final class AppFilesManager {
    
    private init() {}
    
    static var shared = AppFilesManager()
    
    private var writeManager = {
        let manager = WriteFileManager()
        manager.directory = .downloadsDirectory
        return manager
    }()
    
    func write(fileName: String, toDirectoryName: String, data: Data) {
        self.writeManager.directoryName = toDirectoryName
        self.writeManager.write(fileName: fileName, data: data)
    }
    
    func checkfileExistance(fileName: String, onDirectoryName: String) -> Bool {
        
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let path = documentsUrl.appendingPathComponent(onDirectoryName).appendingPathComponent(fileName).path
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    func isDirectoryEmpty(directory: FileManager.SearchPathDirectory, path: String? = nil) -> Bool {
        
        guard var documentsUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return false
        }
        
        if let additionalPath = path {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsUrl.path)
            return !files.isEmpty
        } catch {
            return false
        }
    }
    
    func deleteAppDirectory(onPath: String? = nil) {
        
        guard var documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        if let additionalPath = onPath {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }
        
        if FileManager.default.fileExists(atPath: documentsUrl.path) {
            do {
            try FileManager.default.removeItem(at: documentsUrl)
                print("AppFile: [Success] Delete documentDirectory")
            } catch {
                print("AppFile: [Failed] Delete documentDirectory")
            }
        }
    }
    
    func openFilesApp(forDirectory: FileManager.SearchPathDirectory = .documentDirectory, onPath: String? = nil) {
        
        guard var documentsUrl = FileManager.default.urls(for: forDirectory, in: .userDomainMask).first else {
            return
        }
        
        if let additionalPath = onPath {
            documentsUrl = documentsUrl.appendingPathComponent(additionalPath)
        }

        if let sharedUrl = URL(string: "shareddocuments://\(documentsUrl.path)") {
            if UIApplication.shared.canOpenURL(sharedUrl) {
                UIApplication.shared.open(sharedUrl, options: [:])
            }
        }
    }
}
