//
//  CoreDataManager.swift
//  Mon Compte Free
//
//  Created by Free on 11/05/2021.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func register(dataModelFileName: String)
    func create<T: NSManagedObject>(entity: NSEntityDescription) -> T
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func fetchFirst<T: NSManagedObject>(request: NSFetchRequest<T>) -> T?
    func fetchFirstElseCreate<T: NSManagedObject>(request: NSFetchRequest<T>) -> T
    func delete<T: NSManagedObject>(object: T)
    func saveContext()
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    // MARK: - Properties
    
    static let shared = CoreDataManager()
    private var container: NSPersistentContainer!
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Methods
    
    func register(dataModelFileName: String) {
        self.container = NSPersistentContainer(name: dataModelFileName)
        self.container.loadPersistentStores { _, _ in }
    }
    
    func create<T: NSManagedObject>(entity: NSEntityDescription) -> T {
        return T(entity: entity, insertInto: self.context)
    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    func fetchFirst<T: NSManagedObject>(request: NSFetchRequest<T>) -> T? {
        return self.fetch(request: request).first
    }
    
    func fetchFirstElseCreate<T: NSManagedObject>(request: NSFetchRequest<T>) -> T {
        return self.fetch(request: request).first ?? self.create(entity: T.entity())
    }
    
    func delete<T: NSManagedObject>(object: T) {
        self.context.delete(object)
    }
    
    func saveContext() {
        do {
            if self.context.hasChanges {
                try self.context.save()
            }
        } catch let error {
            #if DEBUG
            print("saveContext() Error => \(error.localizedDescription)")
            #endif
        }
    }
}
