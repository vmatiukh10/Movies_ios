//
//  CoreDataManager.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 17.12.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    // MARK: - Properties
    
    private let modelName: String
    
    // MARK: - Initialization
    
    init(modelName: String = "Movies") {
        self.modelName = modelName
    }
    
    // MARK: - Core Data Stack
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    func getFavorites() -> [FavoriteMovies] {
        var favoriteMovies: [FavoriteMovies] = []
        do {
            favoriteMovies = try managedObjectContext.fetch(FavoriteMovies.fetchRequest())
        } catch {
            print(error)
        }
        return favoriteMovies
    }
    
    func updateFavorite(id: Int, isFavorite: Bool) -> [FavoriteMovies] {
        do {
            let fetch = FavoriteMovies.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", id)
            guard let favorite = try managedObjectContext.fetch(fetch).first else {
                let newObject = FavoriteMovies(context: managedObjectContext)
                newObject.id = Int64(id)
                newObject.isFavorite = isFavorite
                return getFavorites()
            }
            favorite.isFavorite = isFavorite
        } catch {
            print(error)
        }
        return getFavorites()
    }
}
