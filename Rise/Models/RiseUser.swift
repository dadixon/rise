//
//  RiseUser.swift
//  Rise
//
//  Created by Domonique Dixon on 11/29/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import Foundation

class RiseUser {
    
    static let sharedInstance = RiseUser()

    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var companyName: String
    var amountOfPeople: String
    var createdDate: NSNumber
    var isNew: Bool
    
    private init() {
        self.id = UserDefaults.userUID
        self.firstName = UserDefaults.userFirstName
        self.lastName = UserDefaults.userLastName
        self.email = UserDefaults.userEmail
        self.phone = UserDefaults.userPhone
        self.companyName = UserDefaults.userCompany
        self.amountOfPeople = UserDefaults.userAmount
        self.createdDate = 0
        self.isNew = true
    }
    
}
