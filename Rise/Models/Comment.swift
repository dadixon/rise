//
//  Comment.swift
//  Rise
//
//  Created by Domonique Dixon on 2/20/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Comment {
    var date: Date
    var comment: String
    var timestamp: Int64
    
    init(date: Date, comment: String) {
        self.date = date
        self.comment = comment
        self.timestamp = Timestamp().seconds
    }
    
    init(date: Date, comment: String, timestamp: Int64) {
        self.date = date
        self.comment = comment
        self.timestamp = timestamp
    }
    
    func print() -> [String: Any] {
        let todayFormatter = DateFormatter()
        todayFormatter.dateFormat = "yyyy-M-dd"
        let stringDate = todayFormatter.string(from: self.date)
        
        return [
            "date": stringDate,
            "note": self.comment.base64Encode()!,
            "timestamp": self.timestamp
        ]
    }
}
