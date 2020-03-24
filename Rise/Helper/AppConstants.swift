//
//  AppConstants.swift
//  Rise
//
//  Created by Domonique Dixon on 1/20/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation
import UIKit

struct Design {
    struct Color {
        struct ListNotes {
            static let noNotes = UIColor(named: "noNotes")
            static let aqua = UIColor(named: "warningStatusNotes") //UIColor.rgba(red: 153, green: 245, blue: 251, alpha: 1)
            static let lightBlue = UIColor(named: "outdatedStatusNotes") //UIColor.rgba(red: 133, green: 194, blue: 248, alpha: 1)
        }
        
        struct Primary {
            static let aquamarine = UIColor(named: "goodStatusNotes") //UIColor.rgba(red: 153, green: 251, blue: 218, alpha: 1)
        }
        
        struct Secondary {
            static let darkGrey = UIColor.rgba(red: 111, green: 111, blue: 111, alpha: 1)
        }
    }
}

struct Content {
    
}
