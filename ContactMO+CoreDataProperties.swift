//
//  ContactMO+CoreDataProperties.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactMO> {
        return NSFetchRequest<ContactMO>(entityName: "ContactMO")
    }

    @NSManaged public var email: String?
    @NSManaged public var image: Data?
    @NSManaged public var phoneNumber: String?

}
