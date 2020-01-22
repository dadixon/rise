//
//  CoreDataManager.swift
//  Rise
//
//  Created by Domonique Dixon on 1/20/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Rise")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertEmployee(name: String, userID: String, completion: @escaping (_ error: Error?) -> Void) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let employee = Employee(context: context)
        
        employee.fullName = name
        employee.latest = nil
        employee.userId = userID
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func updateEmployee(name: String, employee: Employee, completion: @escaping (_ error: Error?) -> Void) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        employee.setValue(name, forKey: "fullName")
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteEmployee(employee: Employee, completion: @escaping (_ error: Error?) -> Void) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        context.delete(employee)
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func getEmployees(completion: @escaping (_ error: Error?) -> Void) -> [Employee]? {
        var employees: [Employee]?
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latest", ascending: UserDefaults.sortOrder)
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            employees = try context.fetch(request)
            completion(nil)
            return employees
        } catch {
            completion(error)
        }
        
        return nil
    }
}
