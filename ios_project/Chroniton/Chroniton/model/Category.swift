
import Foundation
import CoreData


// CoreData-related extensions
// Note: Xcode automatically generates base class definition based on properties in Core Data model file
extension Category {
    
    // Ordered fetch request will be created to order by this field:
    static let DEFAULT_ORDERING_FIELD = "orderIndex"
    
    
    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.name = name
        self.orderIndex = -1  // owner is responsible for making sure this gets set to a proper value on save
    }
    
    // Boilerplate:
    // Convenience wrapper to generate CoreData entity description for this model object type
    class func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Category", in: context)!
    }
    
    
    class func orderedFetchRequest() -> NSFetchRequest<Category> {
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        
        let sort = NSSortDescriptor(key: DEFAULT_ORDERING_FIELD, ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        return fetchRequest
    }
    
    // A great deal of code in the app assumes "... = someCategory.name!" is always valid.
    // Enforce this, for safety (should never acutually be possible, by UI)
    public override func willSave() {
        if self.name == nil || self.name == "" {
            self.name = "New Category"
        }
    }
    
    // wrapper for .events that returns same set, but as an array ordered by event.orderIndex
    func orderedEvents() -> [Event] {
        if
            let set = self.events,
            var events = set.allObjects as? [Event]
        {
            events.sort { $0.orderIndex <= $1.orderIndex }
            return events
        }
        else {
            return []
        }
    }
}



extension Category {
    
    func toEmailAsText() -> String {
        let title = NSLocalizedString("Category", comment: "Category Title")
        return "\(title): \(name ?? "(no name)")\n"
    }
    
    
    func toCsvString() -> String {
        return (self.name ?? "").escapeAsCSVData()
    }
    
}


extension Category {
    
    func _log(withIndent indent: String?) -> String {
        return "\(indent ?? "")Category : [\(orderIndex)]  \(name ?? "(no name)") : (\(String(describing: objectID)))"
    }

}
