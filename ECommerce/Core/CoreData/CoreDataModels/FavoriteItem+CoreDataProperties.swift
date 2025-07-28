//
//  FavoriteItem+CoreDataProperties.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import CoreData



// MARK: - FavoriteItem+CoreDataProperties.swift
extension FavoriteItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteItem> {
        return NSFetchRequest<FavoriteItem>(entityName: "FavoriteItem")
    }
    
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var productImage: String?
    @NSManaged public var productPrice: String?
    @NSManaged public var productBrand: String?
    @NSManaged public var productModel: String?
}
