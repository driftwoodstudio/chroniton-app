
import Foundation
import CoreData


// CoreData-related extensions
// Note: Xcode automatically generates base class definition based on properties in Core Data model file
extension Event {
    
    // Ordered fetch request will be created to order by this field:
    static let DEFAULT_ORDERING_FIELD = "orderIndex"

    
    convenience init(context: NSManagedObjectContext, title: String) {
        self.init(context: context)
        self.title = title
        self.orderIndex = -1  // owner is responsible for making sure this gets set to a proper value on save
    }

    // Boilerplate:
    // Convenience wrapper to generate CoreData entity description for this model object type
    class func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Event", in: context)!
    }
    
    
    class func orderedFetchRequest() -> NSFetchRequest<Event> {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        let sort = NSSortDescriptor(key: DEFAULT_ORDERING_FIELD, ascending: true)
        fetchRequest.sortDescriptors = [sort]
        return fetchRequest
    }

    class func orderedFetchRequest(forCategory category: Category) -> NSFetchRequest<Event> {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        let sort = NSSortDescriptor(key: DEFAULT_ORDERING_FIELD, ascending: true)
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.sortDescriptors = [sort]
        
        return fetchRequest
    }

    // A great deal of code in the app assumes "... = someEvent.title!" is always valid.
    // Enforce this, for safety (should never acutually be possible, by UI)
    public override func willSave() {
        if self.title == nil || self.title == "" {
            self.title = "New Event"
        }
    }

}



extension Event {
    
    // Note that Event MUST belong to a category, but that's not represented/enforced here.
    
    // Due if:
    //   has due date + blank last-on date
    //   has due date + last-on date before due date
    func isDue() -> Bool {
        return isDue(withinDays: 0)
    }
    
    
    func isDue(withinDays numDays: Int) -> Bool {
        // No, if no due date
        guard let dueDate = nextDate else {
            // no due date
            return false
        }
        
        // Never done?
        guard let lastOnDate = lastDate else {
            // Due date, and never done
            return true
        }
        
        // Last done before due date?
        if lastOnDate.compare(dueDate) != .orderedAscending {
            return false
        }
        
        // Due within days count
        let endOfToday = Date().endOfDayInLocalTimezone
        let endDate = endOfToday.addDays(numDays)
        if dueDate.compare(endDate) != .orderedAscending {
            return false
        }
        
        return true
    }
    
    func toEmailAsText(indent i:String) -> String {
        let lastDateStr = self.lastDate?.asShortFormatString() ?? ""
        let nextDateStr = self.nextDate?.asShortFormatString() ?? ""
        let out =
            "\n" + i + NSLocalizedString("Event", comment: "Email field title")+": \(self.title ?? "(no title)")" +
                "\n  " + i + NSLocalizedString("Last On", comment: "Email field title")+": \(lastDateStr)" +
                "\n  " + i + NSLocalizedString("Next On", comment: "Email field title")+": \(nextDateStr)" +
                "\n  " + i + NSLocalizedString("Notes", comment: "Email and CSV field title")+": \n\(self.notes ?? "")\n"
        return out
    }
    
    
    static func csvHeaderLine() -> String {
        return "\"\(NSLocalizedString("Category", comment: "CSV ColumnTitle"))\",\"\(NSLocalizedString("Title", comment: "Email and CSV field title"))\",\"\(NSLocalizedString("LastDate", comment: "CSV Column Title"))\",\"\(NSLocalizedString("NextDate", comment: "CSV Column Title"))\",\"\(NSLocalizedString("Notes", comment: ""))\"\n"
    }
    
    
    func toCsvString() -> String {
        let SEP = ","
        let str =
            (title ?? "").escapeAsCSVData() + SEP +
                DateStrHelper.toString(lastDate).escapeAsCSVData() + SEP +
                DateStrHelper.toString(nextDate).escapeAsCSVData() + SEP +
                (notes ?? "").escapeAsCSVData()
        return str
    }
    
}


extension Event {
    
    func _log(withIndent indent: String?) -> String {
        return
            "\(indent ?? "")  [\(orderIndex)] \(title ?? "(no title)")  : (\(String(describing: objectID)))"
                + "\n\(indent ?? "")  lastDate: \(String(describing: lastDate))"
                + "\n\(indent ?? "")  nextDate: \(String(describing: nextDate))"
                + "\n\(indent ?? "")  image   : \(String(describing: imageData))"
    }

}
