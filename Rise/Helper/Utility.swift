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
//        var convertedArray: [Date] = []
//
//        for dat in notes {
//            convertedArray.append(dat.created!)
//        }
        
//        let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        
        return notes.sorted(by: { $0.created!.compare($1.created!) == .orderedDescending })
    }
    
    static func cellColor(from date:Date) -> UIColor {
        guard let diffInDays = Calendar.current.dateComponents([.day], from: date, to: Date()).day else {
            SVProgressHUD.showError(withStatus: "Unable to process")
            return UIColor.white
        }
        
        if diffInDays >= 0 && diffInDays < 9 {
            return UIColor.lightGray
        } else if diffInDays >= 9 && diffInDays < 10 {
            return UIColor.green
        } else if diffInDays >= 10 {
            return UIColor.red
        }
        
        return UIColor.white
    }
}
