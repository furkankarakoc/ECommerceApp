//
//  CartItem+CoreDataProperties.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import CoreData


// MARK: - CartItem+CoreDataProperties.swift
extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var productImage: String?
    @NSManaged public var productPrice: String?
    @NSManaged public var productBrand: String?
    @NSManaged public var productModel: String?
    @NSManaged public var quantity: Int16
}
