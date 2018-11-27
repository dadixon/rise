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
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssz"
//        let dateString = dateFormatter.string(from: timeManagedReminder)
//        let formattedDate = dateFormatter.date(from: dateString)
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
        Utility.removeOldNotes()
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
        return userDefaults.string(forKey: Defaults.UserUID)!
    }
    class func set(userUID: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userUID, forKey: Defaults.UserUID)
    }
}
