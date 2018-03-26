//
//  FriendsControllerHelper.swift
//  FBMessanger
//
//  Created by SEUNG-WON KIM on 2018/03/22.
//  Copyright © 2018 SEUNG-WON KIM. All rights reserved.
//

import UIKit
import CoreData

extension FriendsViewController {
  
  func setupData() {
    
    clearData()
    
    let delegate = UIApplication.shared.delegate as? AppDelegate

    guard let context = delegate?.persistentContainer.viewContext else { return }

    let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
    mark.name = "Mark Zucherberg"
    mark.profileImageName = "canada"
    FriendsViewController.createMessageWithText(text: "Hey! Are you in home now?", friend: mark, context: context)
    
    createSteveMessageWithContext(context: context)

    
    
    let steve = Friend(context: context)
    steve.name = "Steve Jobs"
    steve.profileImageName = "jamaica"
    FriendsViewController.createMessageWithText(text: "Hello, It is been a while.", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "Are you interested in buying an iPhone?", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "you have to bring your Credit card.", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "Hello, It is been a while.", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "Are you interested in buying an iPhone?", friend: steve, context: context)

 
    do {
      try context.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
    
    loadData()
  }
  
  private func createSteveMessageWithContext(context: NSManagedObjectContext) {
    let steve = Friend(context: context)
    steve.name = "Argentina cole"
    steve.profileImageName = "argentina"
    FriendsViewController.createMessageWithText(text: "Hello, It is been a while.", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "Are you interested in buying an iPhone?", friend: steve, context: context)
    FriendsViewController.createMessageWithText(text: "you have to bring your Credit card.", friend: steve, context: context, isSender: true)
  }
  
  static func createMessageWithText(text: String, friend: Friend, context: NSManagedObjectContext, isSender: Bool = false) {
    let message = Message(context: context) 
    message.friend = friend
    message.text = text
    message.date = NSDate()
    message.isSender = isSender
  }
  
  func clearData() {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = delegate?.persistentContainer.viewContext else { return }
    do {
      
      let entityNames = ["Friend", "Message"]
      for entityName in entityNames {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let objects = try context.fetch(fetchRequest) as? [NSManagedObject] {
          for object in objects{
            context.delete(object)
          }
        }
      }
    } catch let error as NSError {
      print(error)
    }
  }
  
  func loadData() {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = delegate?.persistentContainer.viewContext else { return }
    
    if let friends = fetchFriends() {
      
      messages = [Message]()
      
      for friend in friends {
//        print(friend.name)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
        fetchRequest.fetchLimit = 1
        
        do {
          let fetchMessages = try context.fetch(fetchRequest) as? [Message]
          if let messages = fetchMessages, let message = messages.first {
            self.messages?.append(message)
          }
          
        }catch let error {
          print(error)
        }
      }
      messages = messages?.sorted(by: { (msg1, msg2) -> Bool in
        return msg1.date?.compare(msg2.date! as Date) == .orderedAscending
      })
    }
  }
  
  private func fetchFriends() -> [Friend]? {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    if let context = delegate?.persistentContainer.viewContext {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
      do {
        return try context.fetch(fetchRequest) as? [Friend]
        
      }catch let error {
        print(error)
      }
    }
    return nil
  }
  
}
