//
//  CoreDataManager.swift
//  GMS
//
//  Created by Helly Prakashkumar Chauhan on 2025-03-12.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "GMS")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Save a new user in Core Data
    func saveUser(username: String, fullName: String, email: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                print("User with this email already exists!")
                return false
            }
        } catch {
            print("Error checking existing users: \(error)")
            return false
        }

        let user = User(context: context)
        user.userid = UUID()  // Generates a unique ID
        user.username = username
        user.fullName = fullName
        user.email = email
        user.password = password

        do {
            try context.save()
            print("User saved successfully!")
            return true
        } catch {
            print("Failed to save user: \(error)")
            return false
        }
    }

    /// Fetch a user by email
    func fetchUser(byEmail email: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func fetchCurrentUser() -> User? {
        guard let email = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            print("No current user email found")
            return nil
        }
        return fetchUser(byEmail: email)
    }
    
    func updateUserProfile(user: User, username: String, fullName: String, email: String, password: String, dietPreference: String) -> Bool {
        user.username = username
        user.fullName = fullName
        user.email = email
        user.password = password
        user.dietPreference = dietPreference
        
        do {
            try context.save()
            print("User profile updated successfully!")
            return true
        } catch {
            print("Failed to update profile: \(error)")
            return false
        }
    }
    
    // MARK: - Grocery CRUD Operations

        /// Save a grocery item linked to a specific user
    func addGrocery(
            for user: User,
            name: String,
            expiryDate: Date,
            price: Float,
            purchasedDate: Date,
            quantity: Double,
            unit: String,
            category: String,
            isWasted: Bool = false
        ) {
            let grocery = Grocery(context: context)
            grocery.groceryid = UUID()
            grocery.name = name
            grocery.expiryDate = expiryDate
            grocery.price = price
            grocery.purchasedDate = purchasedDate
            grocery.quantity = quantity
            grocery.unit = unit
            grocery.category = category
            grocery.user = user // Link grocery to the user
            
            // New wastage properties
            grocery.isWasted = isWasted
            if isWasted {
                grocery.wastedDate = Date()
            }
            
            do {
                try context.save()
                print("Grocery saved successfully!")
            } catch {
                print("Failed to save grocery: \(error)")
            }
        }
        
        /// Fetch all groceries for a specific user
        func fetchGroceries(for user: User) -> [Grocery] {
            let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
            request.predicate = NSPredicate(format: "user == %@", user) // Filter by user

            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching groceries: \(error)")
                return []
            }
        }
    
    // MARK: - Fetch active (non-wasted) groceries
        func fetchActiveGroceries(for user: User) -> [Grocery] {
            let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "isWasted == NO")
            ])
            
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching active groceries: \(error)")
                return []
            }
        }
        
        /// Update an existing grocery item
        func updateGrocery(grocery: Grocery, name: String, expiryDate: Date, price: Float, purchasedDate: Date, quantity: Double, unit: String) {
            grocery.name = name
            grocery.expiryDate = expiryDate
            grocery.price = price
            grocery.purchasedDate = purchasedDate
            grocery.quantity = quantity
            grocery.unit = unit

            do {
                try context.save()
                print("Grocery updated successfully!")
            } catch {
                print("Failed to update grocery: \(error)")
            }
        }
        
        /// Delete a grocery item
        func deleteGrocery(_ grocery: Grocery) {
            context.delete(grocery)
            
            do {
                try context.save()
                print("Grocery deleted successfully!")
            } catch {
                print("Failed to delete grocery: \(error)")
            }
        }
    /// Fetch groceries sorted by soonest expiry date
    func fetchSoonestExpiringGroceries(for user: User, limit: Int = 5) -> [Grocery] {
        let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "expiryDate", ascending: true)]
        request.fetchLimit = limit  // Fetch only the top N expiring items

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching soonest expiring groceries: \(error)")
            return []
        }
    }

    func fetchWastedGroceries(for user: User) -> [Grocery] {
            let request: NSFetchRequest<Grocery> = Grocery.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "isWasted == YES")
            ])
            
            // Sort by waste date (newest first)
            request.sortDescriptors = [NSSortDescriptor(key: "wastedDate", ascending: false)]
            
            do {
                return try context.fetch(request)
            } catch {
                print("Error fetching wasted groceries: \(error)")
                return []
            }
        }
        
        // MARK: - Mark a grocery item as wasted
        func markAsWasted(grocery: Grocery) {
            grocery.isWasted = true
            grocery.wastedDate = Date()
            
            do {
                try context.save()
                print("Grocery marked as wasted successfully!")
            } catch {
                print("Failed to mark grocery as wasted: \(error)")
            }
        }
        
        // MARK: - Check for expired groceries and mark them as wasted
        func checkForExpiredGroceries(for user: User) -> Int {
            let today = Date()
            let activeGroceries = fetchActiveGroceries(for: user)
            var expiredCount = 0
            
            for grocery in activeGroceries {
                if let expiryDate = grocery.expiryDate, expiryDate < today {
                    markAsWasted(grocery: grocery)
                    expiredCount += 1
                }
            }
            
            return expiredCount
        }
        
        // MARK: - Get wastage statistics
        func getWastageStatistics(for user: User) -> (total: Int, thisMonth: Int, thisWeek: Int) {
            let wastedItems = fetchWastedGroceries(for: user)
            let currentDate = Date()
            let calendar = Calendar.current
            
            // This month
            let thisMonthItems = wastedItems.filter { grocery in
                guard let wastedDate = grocery.wastedDate else { return false }
                return calendar.isDate(wastedDate, equalTo: currentDate, toGranularity: .month)
            }
            
            // This week
            let thisWeekItems = wastedItems.filter { grocery in
                guard let wastedDate = grocery.wastedDate else { return false }
                return calendar.isDate(wastedDate, equalTo: currentDate, toGranularity: .weekOfYear)
            }
            
            return (wastedItems.count, thisMonthItems.count, thisWeekItems.count)
        }
        
        // MARK: - Get wastage value (total cost of wasted items)
        func getWastageValue(for user: User, period: WastageTimePeriod = .allTime) -> Float {
            let wastedItems = fetchWastedGroceries(for: user)
            let currentDate = Date()
            let calendar = Calendar.current
            
            let filteredItems: [Grocery]
            
            switch period {
            case .thisWeek:
                filteredItems = wastedItems.filter { grocery in
                    guard let wastedDate = grocery.wastedDate else { return false }
                    return calendar.isDate(wastedDate, equalTo: currentDate, toGranularity: .weekOfYear)
                }
            case .thisMonth:
                filteredItems = wastedItems.filter { grocery in
                    guard let wastedDate = grocery.wastedDate else { return false }
                    return calendar.isDate(wastedDate, equalTo: currentDate, toGranularity: .month)
                }
            case .thisYear:
                filteredItems = wastedItems.filter { grocery in
                    guard let wastedDate = grocery.wastedDate else { return false }
                    return calendar.isDate(wastedDate, equalTo: currentDate, toGranularity: .year)
                }
            case .allTime:
                filteredItems = wastedItems
            }
            
            // Sum up the total cost
            return filteredItems.reduce(0) { $0 + $1.price }
        }
        
        // MARK: - Save context helper
        func saveContext() {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error)")
                }
            }
        }

}

// Time period enum for wastage statistics
enum WastageTimePeriod {
    case thisWeek
    case thisMonth
    case thisYear
    case allTime
}
