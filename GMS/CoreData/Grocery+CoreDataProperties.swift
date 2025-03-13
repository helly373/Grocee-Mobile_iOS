//
//  Grocery+CoreDataProperties.swift
//  GMS
//
//  Created by Fernando Chávez Solares on 2025-03-13.
//
//

import Foundation
import CoreData


extension Grocery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grocery> {
        return NSFetchRequest<Grocery>(entityName: "Grocery")
    }

    @NSManaged public var groceryid: UUID?
    @NSManaged public var name: String?
    @NSManaged public var unit: String?
    @NSManaged public var quantity: Double
    @NSManaged public var price: Float
    @NSManaged public var purchasedDate: Date?
    @NSManaged public var expiryDate: Date?
    @NSManaged public var user: User?

}

extension Grocery : Identifiable {

}
