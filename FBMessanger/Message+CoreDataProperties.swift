//
//  Message+CoreDataProperties.swift
//  FBMessanger
//
//  Created by SEUNG-WON KIM on 2018/03/23.
//  Copyright © 2018 SEUNG-WON KIM. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isSender: Bool
    @NSManaged public var text: String?
    @NSManaged public var friend: Friend?

}
