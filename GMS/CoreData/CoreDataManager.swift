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


}

