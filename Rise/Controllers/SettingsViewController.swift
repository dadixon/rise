//
//  SettingsViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 10/26/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Eureka
import UserNotifications

class SettingsViewController: FormViewController {

    let userDefault = UserDefaults.standard
    
    struct FormItems {
        static let name = "name"
        static let birthDate = "birthDate"
        static let like = "like"
        static let order = "asc"
        static let days = "days"
        static var repeatFreq = "daily"
        static let repeatOptions = ["daily"]
        static let sortOptions = ["Ascending", "Descending"]
    }
    
    struct FormData {
        static var useTimeManagedReminder = false
        static var timeManagedReminder: Date? = nil
        static var repeatFreq: String? = nil
        static var reminderStartDays: Int? = nil
        static var storeDays: Int? = nil
        static var sortOrder: String? = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        var startDate: Date? = nil
        
        if UserDefaults.timeManagedReminder != nil {
            startDate = UserDefaults.timeManagedReminder!
        }
        
        form
            +++ Section(header: "Reminders", footer: "These settings change when the reminders will display.")
            <<< SwitchRow("timeManagedReminders"){
                $0.title = "Time Managed"
                $0.value = UserDefaults.useTimeManagedReminder
                $0.onChange{ [unowned self] row in
                    if ((self.form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value)! {
                        self.registerNotification()
                    } else {
                        self.cancelNotification()
                    }
                }
            }
            <<< DateTimeRow("reminderStartDateTime") {
                $0.hidden = Condition.function(["timeManagedReminders"], { form in
                    let useTimeManagedReminder = ((form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value ?? false)
                    UserDefaults.set(useTimeManagedReminder: useTimeManagedReminder)
                    return !((form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Start Date"
                $0.minimumDate = Date()
                $0.value = startDate
                $0.onChange { [unowned self] row in
                    self.cancelNotification()
                    
                    if let newDate = row.value {
                        UserDefaults.set(timeManagedReminder: newDate)
                        self.createNotification(date: newDate)
                    }
                }
                }
            <<< PushRow<String>() {
                $0.hidden = Condition.function(["timeManagedReminders"], { form in
                    return !((form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Repeats"
                $0.value = FormItems.repeatFreq
                $0.options = FormItems.repeatOptions
                $0.onChange { [unowned self] row in
                    self.userDefault.set(row.value, forKey: Defaults.RepeatFreq)
                }
                }
                .cellSetup({ (cell, row) in
                    self.userDefault.set(row.value, forKey: Defaults.RepeatFreq)
                })
            <<< StepperRow()
                .cellSetup({ (cell, row) in
                    row.title = "Days before reminders"
                    row.value = Double(UserDefaults.reminderStartDays)
                    cell.valueLabel!.text = "\(Int(row.value!))"
                    cell.stepper.minimumValue = 0.0
                    cell.stepper.maximumValue = 100.0
                }).cellUpdate({ (cell, row) in
                    if(row.value != nil)
                    {
                        cell.valueLabel!.text = "\(Int(row.value!))"
                    }
                }).onChange({ (row) in
                    self.userDefault.set(Int(row.value!), forKey: Defaults.ReminderStartDays)
                    
                    if(row.value != nil)
                    {
                        row.cell.valueLabel!.text = "\(Int(row.value!))"
                    }
                })
            +++ Section("General")
            <<< StepperRow()
                .cellSetup({ (cell, row) in
                    row.title = "Store notes days"
                    row.value = Double(UserDefaults.storeDays)
                    cell.valueLabel!.text = "\(Int(row.value!))"
                    cell.stepper.minimumValue = 40.0
                    cell.stepper.maximumValue = 100.0
                }).cellUpdate({ (cell, row) in
                    if(row.value != nil)
                    {
                        cell.valueLabel!.text = "\(Int(row.value!))"
                    }
                }).onChange({ (row) in
                    self.userDefault.set(Int(row.value!), forKey: Defaults.StoreDays)
                    if(row.value != nil)
                    {
                        row.cell.valueLabel!.text = "\(Int(row.value!))"
                    }
                })
            <<< SegmentedRow<String>(){
                $0.title = "Sort order"
                $0.value = UserDefaults.sortOrder
                $0.options = FormItems.sortOptions
                $0.onChange { row in
                    UserDefaults.set(sortOrder: row.value!)
                }
                }
                .cellSetup({ (cell, row) in
                    self.userDefault.set(row.value, forKey: Defaults.SortOrder)
                })
            +++ Section("Account")
            <<< LabelRow(){ row in
                row.title = "Change Email Account"
                }.onCellSelection({ (cell, row) in
                    print("Change email")
                    //                self.performSegue(withIdentifier: "yourSegue", sender: self)
                })
            <<< LabelRow(){ row in
                row.title = "Change Password"
                }.onCellSelection({ (cell, row) in
                    print("Change password")
                    //                    self.performSegue(withIdentifier: "yourSegue", sender: self)
                })
            <<< ActionSheetRow<String>() {
                $0.title = "Delete Account"
                $0.selectorTitle = "Are you sure you want to delete your account?"
                $0.options = ["Yes"]
            }
            <<< LabelRow(){ row in
                row.title = "Logout"
                }.onCellSelection({ (cell, row) in
                    print("Logout")
                })
            +++ Section("Pre-fill")
            <<< ButtonRow { row in
                row.title = "Print Values"
                }.onCellSelection({ [unowned self] (cell, row) in
                    print(self.form.values())
                    print(UserDefaults.useTimeManagedReminder)
                    print(UserDefaults.timeManagedReminder)
//                    print(FormData.repeatFreq)
                    print(UserDefaults.reminderStartDays)
                    print(UserDefaults.storeDays)
                    print(UserDefaults.sortOrder)
                })
    }
    
    private func registerNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    private func createNotification(date: Date) {
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Hey this is Simplified iOS"
        content.subtitle = "iOS Development is fun"
        content.body = "We are learning about iOS Local Notification"
        content.badge = 1
        content.categoryIdentifier = "customIdentifier"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let userCalendar = Calendar.current
        let dailyComponents: Set<Calendar.Component> = [
            .hour,
            .minute
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.dateComponents(dailyComponents, from: date)
        
        
        //everyday at 10:30am
        //        var dateComponents = DateComponents()
        //        dateComponents.hour = 10
        //        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateTimeComponents, repeats: true)
        
        //getting the notification trigger
        //it will be called after 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
