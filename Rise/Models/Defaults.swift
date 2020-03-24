//
//  Defaults.swift
//  Rise
//
//  Created by Domonique Dixon on 10/26/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import Foundation

struct Defaults {
    private init() {}
    
    static let UseTimeManagedReminder = "useTimeManagedReminder"
    static let TimeManagedReminder = "timeManagedReminder"
    static let RepeatFreq = "repeatFreq"
    static let ReminderStartDays = "reminderStartDays"
    static let StoreDays = "storeDays"
    static let SortOrder = "sortOrder"
    static let MainTitle = "mainTitle"
    static let UserFirstName = "userFirstName"
    static let UserLastName = "userLastName"
    static let UserPhone = "userPhone"
    static let UserCompany = "userCompany"
    static let UserAmount = "userAmount"
    static let UserUID = "userUID"
    static let UserEmail = "userEmail"
    static let UserCreatedDate = "userCreatedDate"
    static let UserIsNew = "userIsNew"
}

extension UserDefaults {
    class var useTimeManagedReminder: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: Defaults.UseTimeManagedReminder)
    }
    class func set(useTimeManagedReminder: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(useTimeManagedReminder, forKey: Defaults.UseTimeManagedReminder)
    }
    
    class var timeManagedReminder: Date? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: Defaults.TimeManagedReminder) as? Date
    }
    class func set(timeManagedReminder: Date) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(timeManagedReminder, forKey: Defaults.TimeManagedReminder)
    }
    
    class var sortOrder: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: Defaults.SortOrder)
    }
    class func set(sortOrder: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(sortOrder, forKey: Defaults.SortOrder)
    }
    
    class var storeDays: Int {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: Defaults.StoreDays)
    }
    class func set(storeDays: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(storeDays, forKey: Defaults.StoreDays)
//        if storeDays < 101 {
//            Utility.deleteAllOldNotes { (error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//            }
//        }
    }
    
    class var reminderStartDays: Int {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: Defaults.ReminderStartDays)
    }
    class func set(reminderStartDays: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(reminderStartDays, forKey: Defaults.ReminderStartDays)
    }
    
    class var mainTitle: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.MainTitle)!
    }
    class func set(mainTitle: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(mainTitle, forKey: Defaults.MainTitle)
    }
    
    class var userFirstName: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserFirstName)!
    }
    class func set(userFirstName: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userFirstName, forKey: Defaults.UserFirstName)
    }
    
    class var userLastName: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserLastName)!
    }
    class func set(userLastName: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userLastName, forKey: Defaults.UserLastName)
    }
    
    class var userPhone: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserPhone)!
    }
    class func set(userPhone: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userPhone, forKey: Defaults.UserPhone)
    }
    
    class var userCompany: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserCompany)!
    }
    class func set(userCompany: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userCompany, forKey: Defaults.UserCompany)
    }
    
    class var userAmount: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserAmount)!
    }
    class func set(userAmount: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userAmount, forKey: Defaults.UserAmount)
    }
    
    class var userUID: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserUID) ?? ""
    }
    class func set(userUID: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userUID, forKey: Defaults.UserUID)
    }
    
    class var userEmail: String {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: Defaults.UserEmail)!
    }
    class func set(userEmail: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userEmail, forKey: Defaults.UserEmail)
    }
    
    class var userCreatedDate: Int {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: Defaults.UserCreatedDate)
    }
    class func set(userCreatedDate: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userCreatedDate, forKey: Defaults.UserCreatedDate)
    }
    
    class var userIsNew: Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: Defaults.UserIsNew)
    }
    class func set(userIsNew: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userIsNew, forKey: Defaults.UserIsNew)
    }
}
