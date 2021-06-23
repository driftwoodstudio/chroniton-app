//
//  Model.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit
import CoreData


class Model: NSObject {


    // Gets all records, sorted by default ordering field (see Category for its default ordering field)
    func allCategories() -> [Category] {
        let context = CoreDataManager.context()
        let fetchRequest = Category.orderedFetchRequest()
        do {
            let all = try context.fetch(fetchRequest)
            /* Debug logging:
            var str = "allCategories()"; for c in all { str += "\n  [\(c.orderIndex)] \(c.name!)" }
            AppLogger().logDebug(str)
            */
            return all
        }
        catch let error as NSError {
            AppLogger().logError("Could not fetch Category records", error: error)
            return []
        }
    }

  
    // Gets all records, sorted by default ordering field (see Event for its default ordering field)
    func allEvents() -> [Event] {
        let context = CoreDataManager.context()
        let fetchRequest = Event.orderedFetchRequest()
        do {
            let all = try context.fetch(fetchRequest)
            return all
        }
        catch let error as NSError {
            AppLogger().logError("Could not fetch Event records", error: error)
            return []
        }
    }

    
    // MARK: - Add / Delete
    
    // WARNING:
    //   Category ordering is maintained by the category.orderIndex field values.
    //   Event ordering is maintained by the category.events NSOrderedSet values.
    //
    //   Because of this, manually inserting/removing Category and Event records will cause chaos
    //   when the ordering information is not maintained properly.
    //
    //   To add/remove/reorder Category and Event records, use only the functions provided here.
    
    
    // Create and save new category record ordered at the given index, pushing down existing
    // category records to make room at that index
    func createNewCategory(name: String, insertingAtIndex index: Int? = nil) -> Category {
        let context = CoreDataManager.context()

        // Adjust order index of other categories to accomodate, before inserting
        let all = allCategories()  // is ordered by orderIndex
        let atIndex = index ?? all.count
        for existing in all {
            // bump all indexes at/above target up by 1
            if existing.orderIndex >= atIndex {
                existing.orderIndex += 1
            }
        }
        
        // Create
        let category = Category(context: context, name: name)
        category.orderIndex = Int64(atIndex)

        CoreDataManager.saveContext()
        return category
    }
    

    // Remove existing record and save context
    // Adjusts orderIndex of remaining records to be continuous
    func deleteCategory(_ category: Category) {
        let context = CoreDataManager.context()
        let indexRemoved = category.orderIndex  // index of item that is being deleted
        let all = allCategories()  // is ordered by orderIndex
        for existing in all {
            // drop all indexes above this down by 1
            if existing.orderIndex > indexRemoved {
                existing.orderIndex -= 1
            }
        }
        context.delete(category)
        CoreDataManager.saveContext()
    }
    
    
    // Move existing category to new position in .orderIndex values
    // Adjust other records to fill in "hole" left by moving item
    func moveCategory(_ category: Category, toIndex targetIndex: Int) {
        
        // Goal: Assign new .orderIndex values to all Category records
        
        AppLogger().logDebug("Model: moving " + category._log(withIndent: "") + "  to: \(targetIndex)")
        
        var revised = allCategories().filter({ $0 != category })
        revised.insert(category, at: targetIndex)
        // Renumber category records so .orderIndex reflects new actual order
        for i in (0..<revised.count) {
            revised[i].orderIndex = Int64(i)
        }
        
        var str = "Model.moveCategory(): final order of categories is: "; for c in revised { str += "\n  [\(c.orderIndex)] \(c.name!)" }
        AppLogger().logDebug(str)

        // Can discard the 'revised' array -- it was just a frame for holding Category
        // objects in a fixed order while they were assigned new .orderIndex values

        CoreDataManager.saveContext()
    }

    
    // Create and save new event record ordered at the given index, pushing down existing
    // category records to make room at that index (default insert at top, index 0)
    func createNewEvent(title: String,
                        in category: Category,
                        insertingAtIndex: Int? = nil)
        -> Event
    {
        // New event with category as parent
        let context = CoreDataManager.context()
        let event = Event(context: context, title: title)
        event.category = category
        
        // Existing events in category need to be re-orderIndex'd
        let events: [Event] = category.orderedEvents()  // writable copy as array        let index = insertingAtIndex ?? 0
        
        let index = insertingAtIndex ?? events.count

        for existing in events {
            // bump all indexes at/above target up by 1
            if existing.orderIndex >= Int64(index) {
                existing.orderIndex += 1
            }
        }
        
        // New event at opened index
        event.orderIndex = Int64(index)
        
        CoreDataManager.saveContext()
        return event
    }
    

    // Convenience wrapper for createNewEvent() that allows specifying field values
    func createNewEvent(title: String,
                        notes: String?,
                        lastDate: Date?,
                        nextDate: Date?,
                        in category: Category,
                        insertingAtIndex index: Int? = nil)
        -> Event
    {
        let e = createNewEvent(title: title, in: category, insertingAtIndex: index)
        e.lastDate = lastDate
        e.nextDate = nextDate
        e.notes = notes
        return e
    }
    
        
    // Remove existing record and save context
    // Adjusts orderIndex of remaining events in same category to be continuous
    func deleteEvent(_ event: Event) {
        let context = CoreDataManager.context()
        let category = event.category!  // grab BEFORE removing event, as that will remove from Category
        event.category = nil
        context.delete( event )
        let remainingEvents = category.orderedEvents()
        for i in (0..<remainingEvents.count) {
            remainingEvents[i].orderIndex = Int64(i)
        }

        CoreDataManager.saveContext()

        let list = category.orderedEvents()
        var str = "Delete Event: event list is now: [\(list.count) events]"
        for e in category.orderedEvents() { str += ("\n  [\(e.orderIndex)] \(e.title ?? "(nil)")"); }
        AppLogger().logDebug(str)
        
    }

    
    func moveEvent(_ event: Event, toNewIndex index: Int) {
        let category = event.category!
        // Moving internally within same category
        var eventList = category.orderedEvents()
        // Remove event and re-add in new index
        eventList = eventList.filter({ $0 != event })
        eventList.insert(event, at: index)
        // Renumber .orderIndex's to match actual current order
        for i in (0..<eventList.count) {
            eventList[i].orderIndex = Int64(i)
        }
        category.events = NSSet(array: eventList)
        
        AppLogger().logDebug("Move Event: event list is now:")
        for e in eventList { AppLogger().logDebug("[\(e.orderIndex)] \(e.title ?? "(nil)")"); }
        
        CoreDataManager.saveContext()
    }
    
    
    // Remove event from current category and add to end of events in new category
    func moveEvent(_ event: Event, toNewCategory toCategory: Category, atIndex: Int? = nil) {
        
        guard toCategory != event.category else { moveEvent(event, toNewIndex: atIndex ?? 0);  return }
        
        // Move from category A to category B
        // Note: adding event to new category will auto-remove it from old category, as
        //       event can only associate itself with one Category record
        
        let fromCategory = event.category!
        let targetIndex = atIndex ?? 0
        
        // Insert event in new category's Event list
        var eventList = toCategory.orderedEvents()
        eventList.insert(event, at: targetIndex)
        // Set .orderIndex's to match actual current order
        for i in (0..<eventList.count) {
            eventList[i].orderIndex = Int64(i)
        }
        toCategory.events = NSSet(array: eventList)
        
        AppLogger().logDebug("Move Event: destination event list is now:")
        for e in toCategory.orderedEvents() {  AppLogger().logDebug("[\(e.orderIndex)] \(e.title ?? "(nil)")");  }
        
        // Fix fromCategory's event list (now has invalid event.orderIndex's)
        let remainingEvents = fromCategory.orderedEvents()
        for i in (0..<remainingEvents.count) {
            remainingEvents[i].orderIndex = Int64(i)
        }
        fromCategory.events = NSSet(array: remainingEvents)
        
        AppLogger().logDebug("Move Event: source event list is now:")
        for e in fromCategory.orderedEvents() { AppLogger().logDebug("[\(e.orderIndex)] \(e.title ?? "(nil)")"); }
        
        CoreDataManager.saveContext()
    }
    
    
    func _test_deleteAllData() {
        
        let context = CoreDataManager.context()
        
        // Note on batch deleting data:
        // Using batched delete request does NOT trigger update to NSFetchedResultsController and delegate call
        // If you expect NSFetchedResultsController to notice changes, doing this won't work:
        //   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        //   let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest )
        //   batchDeleteRequest.resultType = .resultTypeCount
        //   let batchDeleteResult = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let results = try context.fetch(fetchRequest)
            for obj in results {
                context.delete(obj as! NSManagedObject)
            }
            CoreDataManager.saveContext()
            AppLogger().logDebug("(All categories deleted -- should have cascade-deleted all events as well)")
        }
        catch let error as NSError {
            AppLogger().logError("deleteAllData() error", error: error)
        }
    }

    func _test_deleteAllEvents() {
        
        let context = CoreDataManager.context()
        
        // Note on batch deleting data:
        // Using batched delete request does NOT trigger update to NSFetchedResultsController and delegate call
        // If you expect NSFetchedResultsController to notice changes, doing this won't work:
        //   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        //   let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest )
        //   batchDeleteRequest.resultType = .resultTypeCount
        //   let batchDeleteResult = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let results = try context.fetch(fetchRequest)
            for obj in results {
                context.delete(obj as! NSManagedObject)
            }
            CoreDataManager.saveContext()
            AppLogger().logDebug("_test_deleteAllEvents() :  All Events deleted")
        }
        catch let error as NSError {
            AppLogger().logError("_test_deleteAllEvents() error", error: error)
        }
    }

}



extension Model {
    
    func firstEvent() -> Event? {
        for c in allCategories() {
            let events = c.orderedEvents()
            if events.count > 0 {
                return events[0]
            }
        }
        return nil
    }
    
    
    // Count anything due today + future numDays
    // (so numDays:0 means "today", numDays:1 means "today and tomorrow")
    // Do not count anything due today that has a last-on date today
    func countDueEvents(inDays numDays: Int) -> Int {
        var count = 0
        for c in allCategories() {
            for e in c.orderedEvents() {
                if e.isDue(withinDays: numDays) {
                    count += 1
                }
            }
        }
        return count
    }

    
    func buildPath(for event: Event) -> IndexPath {
        guard
            let category = event.category,
            let section = allCategories().firstIndex(where: {$0 == category}),
            let row = category.orderedEvents().firstIndex(where: {$0 == event})
            else {
                // Really no way this can happen, given that we found Category from Event
                // But leave consistency check just in case there's a glitch or "find category" code changes somehow
                AppLogger().logError("Internal consistency issue: buildPath() for category/event that does not match actual data")
                return IndexPath(row: -1, section: -1)
        }
        let path = IndexPath(row: row, section: section)
        return path
    }

}



extension Model {
    
    func toEmailAsText() -> String {
        var out = ""
        for c: Category in allCategories() {
            out += c.toEmailAsText() + "\n"
            for e in c.orderedEvents() {
                out += e.toEmailAsText(indent: "  ")
            }
        }
        return out
    }
    
    
    class func csvHeaderLine() -> String {
        return Event.csvHeaderLine()
    }
    
    
    func toCsvString() -> String {
        var result = ""
        for c: Category in allCategories() {
            let categoryPefix = c.toCsvString()
            for e in c.orderedEvents() {
                let eventStr = e.toCsvString()
                result = result + categoryPefix + ", " + eventStr + "\n"
            }
        }
        return result
    }
    
    
    static let LOG = true
    
    func _log() {
        if Model.LOG {
            var eventCount = 0
            var str = "Model Staus:"
            for c: Category in allCategories() {
                str += "\n" + c._log(withIndent: " ")
                str += "\n   Events:"
                let events = c.orderedEvents()
                eventCount += events.count
                for e in events {
                    str += "\n" + e._log(withIndent: "   ")
                }
            }
            AppLogger().logDebug(str)
            
            // Consistency check: flag if there are events not attached to categories
            let events = self.allEvents()
            if events.count != eventCount {
                AppLogger().logError("Found \(eventCount) events attached to Categories, but there are \(events.count) events total")
            }
        }
    }

}
