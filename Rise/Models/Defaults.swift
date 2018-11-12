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
}
