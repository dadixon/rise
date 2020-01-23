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
    
    func getEmployees(predicates: NSCompoundPredicate?, sortedBy: [NSSortDescriptor]?, completion: @escaping (_ error: Error?) -> Void) -> [Employee]? {
        var employees: [Employee]?
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        
        if let predicate = predicates {
            request.predicate = predicate
        }
        
        if let sort = sortedBy {
            request.sortDescriptors = sort
        }
                
        do {
            employees = try context.fetch(request)
            completion(nil)
            return sortNoDateFirst(employees: employees)
        } catch {
            completion(error)
        }
        
        return nil
    }
    
    private func sortNoDateFirst(employees: [Employee]?) -> [Employee]? {
        guard var temp = employees else {
            return nil
        }
        
        temp = temp.filter { $0.latest != nil }
        
        for employee in employees! {
            if employee.latest == nil {
                temp.insert(employee, at: 0)
            }
        }
        
        return temp
    }
}
