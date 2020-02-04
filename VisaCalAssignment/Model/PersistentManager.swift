//
//  PersistentManager.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//

import Foundation
import CoreData

final class PersistentManager{
    
    private init(){}
    
    static let shared = PersistentManager()
    
    func getContacts(completion: @escaping ([Contact]?, Error?) -> ()) {
        persistentContainer.performBackgroundTask { [weak self] (context: NSManagedObjectContext) in
            let request: NSFetchRequest<ContactMO> = ContactMO.fetchRequest()
            
            do{
                let contacts = try context.fetch(request)
                let parsedContacts = self?.parseContacts(contacts: contacts)
                completion(parsedContacts, nil)
            }catch{
                print(error)
                completion(nil, error)
            }
        }
    }
    
    private func parseContacts(contacts: [ContactMO]) -> [Contact] {
        var res = [Contact]()
        for contactMO in contacts {
            if let email = contactMO.email,
                let phone = contactMO.phoneNumber {
                let contact = Contact(email: email, phoneNumber: phone, image: contactMO.image)
                res.append(contact)
            }
        }
        return res
    }
    
    
    func addContact(contact: Contact, completion: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { [weak self] (context: NSManagedObjectContext) in
            let _ = self?.createContact(contact: contact, context: context)
            
            do{
                try context.save()
                completion(nil)
            }catch{
                print(error)
                completion(error)
            }
        }
    }
    
    private func createContact(contact: Contact, context: NSManagedObjectContext) -> ContactMO {
        let contactMO = ContactMO(context: context)
        contactMO.email = contact.email
        contactMO.phoneNumber = contact.phoneNumber
        contactMO.image = contact.image
        
        return contactMO
    }
    
    func removeContact(contact: Contact, completion: @escaping (Error?) -> ()) {
        persistentContainer.performBackgroundTask { (context: NSManagedObjectContext) in
            let request: NSFetchRequest<ContactMO> = ContactMO.fetchRequest()
            let predicate = NSPredicate(format: "email = %@", contact.email)
            request.predicate = predicate
            
            do{
                let res = try context.fetch(request)
                for obj in res {
                    context.delete(obj)
                }
                try context.save()
                
                completion(nil)
            }catch{
                print(error)
                completion(error)
            }
        }
    }

    

    
    
    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "VisaCalAssignment")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
