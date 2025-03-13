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
    func addGrocery(for user: User, name: String, expiryDate: Date, price: Float, purchasedDate: Date, quantity: Double, unit: String, category: String) {
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



}

