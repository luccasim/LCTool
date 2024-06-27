//
//  CoreDataViewModel.swift
//  Mon Compte Free
//
//  Created by Free on 11/03/2024.
//

import Foundation
import CoreData

final class CoreDataStack: ObservableObject {
    
    static let shared = CoreDataStack()
    
    // MARK: - Preview
    
    static var preview: CoreDataStack = {
        let result = CoreDataStack(inMemory: true)
        let moc = result.container.viewContext
        
//        let app = AppPreferences(context: moc)
//        
//        let freemobiles = [
//            "Luc", "Mattéo", "Fabien", "Nathan", "Yahia", "Robert", "Katia"
//        ]
//        
//        let freeboxes = [
//            "SGX", "HelpDesk"
//        ]
//        
//        freeboxes.enumerated().forEach { freebox in
//            let newAccount = FbxAccount(context: moc)
//            newAccount.clientID = freebox.offset.toInt32
//            newAccount.login = freebox.element
//            if app.logged == nil {
//                app.logged = newAccount
//            }
//            app.addToAccounts(newAccount)
//        }
//        
//        freemobiles.forEach { freemobile in
//            let newAccount = MobAccount(context: moc)
//            newAccount.login = freemobile
//            app.addToAccounts(newAccount)
//        }
        
        app.objectWillChange.send()
        
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
        
    private let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "EspaceAbonnee")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { ( _, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Context Managnment
    
    var moc: NSManagedObjectContext {
        container.viewContext
    }
    
    private func create<T: NSManagedObject>(entity: NSEntityDescription) async -> T {
        await withCheckedContinuation { continuation in
            self.moc.performAndWait {
                let result = T(entity: entity, insertInto: self.moc)
                continuation.resume(returning: result)
            }
        }
    }
    
    private func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            self.moc.performAndWait {
                do {
                    let result = try self.moc.fetch(request)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func save() {
        moc.performAndWait {
            guard moc.hasChanges else { return }
            
            do {
                try moc.save()
            } catch {
                print("Failed to save the context:", error.localizedDescription)
            }
        }
    }
    
    func delete(item: NSManagedObject) {
        moc.performAndWait {
            moc.delete(item)
        }
    }
}
