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
import ChameleonFramework

enum ErrorsToThrow: Error {
    case firstNameNotFound
    case lastNameNotFound
    case noteTextNotFound
    case noteCreatedDateNotFound
    case canNotSave
    case fullNameNotFound
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
            return HexColor("99FBDA")!
        } else if diffInDays >= UserDefaults.reminderStartDays - 2 && diffInDays < UserDefaults.reminderStartDays {
            return HexColor("99F5FB")!
        } else if diffInDays >= UserDefaults.reminderStartDays {
            return HexColor("85C2F8")!
        }
        
        return UIColor.white
    }
}
