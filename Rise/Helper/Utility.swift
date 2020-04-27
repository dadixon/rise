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

struct DeleteModel {
    var member: Member
    var comment: Comment
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
            return Design.Color.Primary.aquamarine!
        } else if diffInDays >= UserDefaults.reminderStartDays - 2 && diffInDays < UserDefaults.reminderStartDays {
            return Design.Color.ListNotes.aqua!
        } else if diffInDays >= UserDefaults.reminderStartDays {
            return Design.Color.ListNotes.lightBlue!
        }
        
        return UIColor.white
    }
    
    static func deleteAllOldNotes(members: [Member], completionHandler: @escaping (_ error: Error?) -> Void) {
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.storeDays, to: dateFrom)
        var deleteComments = [DeleteModel]()
        
        for member in members {
            for comment in member.comments {
                if comment.date < dateTo! {
                    deleteComments.append(DeleteModel(member: member, comment: comment))
                }
            }
        }

        if deleteComments.count > 0 {
            FirebaseManager.shared.deleteCommentBatch(data: deleteComments) { (error) in
                if error != nil {
                    completionHandler(error)
                    SVProgressHUD.showError(withStatus: "Issue deleting notes")
                } else {
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    
    static func sortByLatestComment(members: [Member]) -> [Member] {
        var rv = [Member]()
        var tempMembers = [Member]()
        
        for member in members {
            if member.latest == nil {
                rv.append(member)
            } else {
                tempMembers.append(member)
            }
        }
        
        var temp = tempMembers
        
        if UserDefaults.sortOrder {
            temp = tempMembers.sorted(by: {($0).latest!.compare(($1).latest!) == .orderedAscending})
        } else {
            temp = tempMembers.sorted(by: {($0).latest!.compare(($1).latest!) == .orderedDescending})
        }
        
        rv.append(contentsOf: temp)
        
        return rv
    }
    
    static func updateLatestNotes(notes: [Comment]) -> Date? {
        let orderedNotes = notes.sorted(by: {($0).date.compare(($1).date) == .orderedDescending})
        
        if orderedNotes.count > 0 {
            return notes[0].date
        } else {
            return nil
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
