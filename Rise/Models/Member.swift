//
//  Member.swift
//  Rise
//
//  Created by Domonique Dixon on 2/20/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation

struct Member {
    var id: String
    var fullName: String
    var latest: Date?
    var comments: [Comment]
}
