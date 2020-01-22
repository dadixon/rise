//
//  Utility.swift
//  Rise
//
//  Created by Domonique Dixon on 9/15/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import CoreData

enum ErrorsToThrow: Error {
    case fullNameNotFound
    case noteTextNotFound
    case noteCreatedDateNotFound
    case canNotSave
    case tooFarBehind
}

class Utility {
    static func textFormat(from date:Date) -> String {
        let diffInDays = Calendar.current.dateComponents([.day], from: date, to: Date()).day
        
        var rv = ""
        
        switch diffInDays {
        case 0:
            rv = "today"
        case 1:
            rv = "-\(diffInDays!) day"
        default:
            rv = "-\(diffInDays!) days"
        }
        
        return rv
    }
    
    static func sortNotesByDate(notes: [Note]) -> [Note] {        
        return notes.sorted(by: { $0.created!.compare($1.created!) == .orderedDescending })
    }
    
    static func cellColor(from date:Date) -> UIColor {
        guard let diffInDays = Calendar.current.dateComponents([.day], from: date, to: Date()).day else {
            SVProgressHUD.showError(withStatus: "Unable to process")
            return UIColor.white
        }
        
        if diffInDays >= 0 && diffInDays < UserDefaults.reminderStartDays - 2 {
            return Design.Color.Primary.aquamarine
        } else if diffInDays >= UserDefaults.reminderStartDays - 2 && diffInDays < UserDefaults.reminderStartDays {
            return Design.Color.ListNotes.aqua
        } else if diffInDays >= UserDefaults.reminderStartDays {
            return Design.Color.ListNotes.lightBlue
        }
        
        return UIColor.white
    }
    
    static func removeOldNotes() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var rv = [Note]()
        var employees = [Employee]()
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.storeDays, to: dateFrom)
        let storeDaysPredicate = NSPredicate(format: "created < %@", dateTo! as NSDate)
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        request.predicate = storeDaysPredicate
        
        do {
            rv = try context.fetch(request)
            
            for note in rv {
                context.delete(note)
            }
            
            let employeesRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
            
            do {
                employees = try context.fetch(employeesRequest)
                
                for employee in employees {
                    let notes = employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
                    
                    if notes.count > 0 {
                        employee.latest = notes[0].created
                    } else {
                        employee.latest = nil
                    }
                }
                
            } catch {
                
            }
            
            do {
                try context.save()
            } catch {
                
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    static func formatPlural(count: Int, object: String) -> String {
        switch count {
        case 1:
            return object
        default:
            return object + "s"
        }
    }
}

extension UIColor {
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
