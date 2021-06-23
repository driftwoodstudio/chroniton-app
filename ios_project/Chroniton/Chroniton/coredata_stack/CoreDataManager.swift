//
//  CoreDataManager.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import CoreData
 

class CoreDataManager: NSObject {
    
    private static let MODEL_FILE_NAME = "DataModel"
    
    
    // MARK: Public Accessors

    static func startup(then completionCallback: @escaping ()->Void) {
        // This causes instance to get created, which triggers init()
        CoreDataManager.instance.loadCoreDataStack() {
            //CoreDataManager.instance.startMonitoringContextUpdates()
            completionCallback()
        }
    }
    

    // Default context, tied to main thread
    static func context() -> NSManagedObjectContext {
        if let container = CoreDataManager.instance.persistentContainer {
            let context = container.viewContext
            context.automaticallyMergesChangesFromParent = true
            return context
        }
        else {
            fatalError("CoreData context accessed before container is ready")
        }
    }
    

    static func saveContext() {
        CoreDataManager.instance._saveContext()
    }
    
    
    
    // ------------------------------------------------------------------------------------------------------
    
    
    // MARK: Private Init
    
    // Static/class State
    static private var instance = CoreDataManager()
    
    
    // Instance state
    private var persistentContainer: NSPersistentContainer?

    
    private override init() {
        // Private init for singleton
        super.init()
    }


    private func loadCoreDataStack(then completionCallback: @escaping ()->Void) {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: CoreDataManager.MODEL_FILE_NAME)
        
        //        https://www.andrewcbancroft.com/blog/ios-development/data-persistence/getting-started-with-nspersistentcloudkitcontainer/
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            else {
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // Store as instance state
                self.persistentContainer = container
                
                let str = "CoreData initialization: "
                    + "\nPersistent Container: \n  \(container.persistentStoreDescriptions)"
                    + "\ndataFileDirectory: \n  \(CoreDataManager.dataFileDirectory)"
                AppLogger().logInfo( str )
                
                // Init completely finished
                completionCallback()
            }
        })
        
    }
        

    static private var dataFileDirectory: URL {
        return NSPersistentContainer.defaultDirectoryURL()
    }
    
    
    
    // MARK: - Private / Internal
    
    
    private func _saveContext () {
        if
            let context = persistentContainer?.viewContext,
            context.hasChanges
        {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("CoreData context.save() error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


/*
extension CoreDataManager {
    
    private func startMonitoringContextUpdates() {
        guard let context = persistentContainer?.viewContext else { return }
        print("  Registering for context update notifications ")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notify_didSave),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: context )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notify_didChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context )
    }
    
    @objc
    func notify_didSave(_ notification: Notification) {
        // The notification object is the managed object context.
        // The userInfo dictionary contains the following keys:
        // NSInsertedObjectsKey, NSUpdatedObjectsKey, and NSDeletedObjectsKey.
        
        print("\n-- EVENT:  NSManagedObjectContextDidSave \n\(notification)")
        if let info = notification.userInfo {
            for (key, _) in info {
                print("Key: \(key)")
            }
        }
        if let objs = notification.userInfo?[NSInsertedObjectsKey] {
            print("Inserted objects:")
            print(objs)
        }
        if let objs = notification.userInfo?[NSUpdatedObjectsKey] {
            print("Update objects:")
            print(objs)
        }
        if let objs = notification.userInfo?[NSDeletedObjectsKey] {
            print("Deleted objects:")
            print(objs)
        }
        print("-- END")
    }
    
    @objc
    func notify_didChange(_ notification: Notification) {
        // The notification object is the managed object context.
        //The userInfo dictionary contains the following keys:
        //NSInsertedObjectsKey, NSUpdatedObjectsKey, and NSDeletedObjectsKey.
        
        print("\n-- EVENT:  NSManagedObjectContextObjectsDidChange \n\(notification)")
        if let info = notification.userInfo {
            for (key, _) in info {
                print("Key: \(key)")
            }
        }
        if let objs = notification.userInfo?[NSInsertedObjectsKey] {
            print("  Inserted objects:")
            print(objs)
        }
        print("-- END")
    }

}
*/

