//
//  CoreDataService.swift
//  Banane
//
//  Created by Luc on 22/10/2024.
//

import Foundation
import CoreData

public final class CoreDataService: Sendable {
    
    // MARK: - Properties
    
    private let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
        
    init(dataModelFileName: String, inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: dataModelFileName)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        self.container.loadPersistentStores { _, _ in }
    }
    
    func getContext() async -> NSManagedObjectContext {
        container.viewContext
    }
    
    func create<T: NSManagedObject>(entity: T.Type) -> T {
        context.performAndWait {
            return T(entity: T.entity(), insertInto: self.context)
        }
    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        context.performAndWait {
            do {
                return try context.fetch(request)
            } catch {
                return []
            }
        }
    }
    
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate?) -> [T] {
        self.context.performAndWait {
            
            guard let entityName = T.entity().name else {
                return []
            }
            
            let request: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
            
            if let predicate = predicate {
                request.predicate = predicate
            }
            
            do {
                return try context.fetch(request)
            } catch {
                return []
            }
        }
    }
    
    /// Fetches the first entity that matches the predicate; otherwise, creates a new one.
    func first<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate?) -> T {
        if let result: T = fetch(entity: entity, predicate: predicate).first {
            return result
        } else {
            return create(entity: T.self)
        }
    }
    
    func delete<T: NSManagedObject>(object: T) {
        context.perform {
            self.context.delete(object)
        }
    }
    
    func save() {
        context.perform {
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }
    
    func clear<T: NSManagedObject>(entity: T.Type) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: entity.fetchRequest())

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Erreur lors de la suppression des objets : \(error)")
        }
    }
}
