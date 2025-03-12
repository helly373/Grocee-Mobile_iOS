//
//  User+CoreDataProperties.swift
//  GMS
//
//  Created by Helly Prakashkumar Chauhan on 2025-03-12.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var password: String?
    @NSManaged public var userid: UUID?
    @NSManaged public var username: String?
    @NSManaged public var dietPreference: String?

}

extension User : Identifiable {

}
