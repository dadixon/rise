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
import MessageUI
import SVProgressHUD
import CoreData
import Firebase

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
        
        setup()
        
        var startDate: Date? = nil
        
        if UserDefaults.timeManagedReminder != nil {
            startDate = UserDefaults.timeManagedReminder!
        }
        
        form
            +++ Section()
            <<< ButtonRow("Submit Your Winners") {
                $0.title = $0.tag
                $0.baseCell.backgroundColor = UIColor(red: 0/255, green: 171/255, blue: 232/255, alpha: 1)
                $0.baseCell.tintColor = UIColor.white
                $0.baseCell.textLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
            }.onCellSelection({ (cell, row) in
                var mainUrl = "https://myemployees.com/winners?"
                
                if UserDefaults.userFirstName != "" {
                    mainUrl += "first=\(UserDefaults.userFirstName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&"
                }
                
                if UserDefaults.userLastName != "" {
                    mainUrl += "last=\(UserDefaults.userLastName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&"
                }
                
                if UserDefaults.userEmail != "" {
                    mainUrl += "email=\(UserDefaults.userEmail.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&"
                }
                
                if UserDefaults.userCompany != "" {
                    mainUrl += "company=\(UserDefaults.userCompany.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")&"
                }
                
                mainUrl.removeLast()
                
                if let url = URL(string: mainUrl) {
                    UIApplication.shared.open(url)
                }
            })
            +++ Section("Reminders")
            <<< SwitchRow("timeManagedReminders"){
                $0.title = "On/Off"
                $0.value = UserDefaults.useTimeManagedReminder
                $0.onChange{ [unowned self] row in
                    if ((self.form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value)! {
                        self.registerNotification()
                    } else {
                        self.cancelNotification()
                    }
                }
            }
            <<< TimeRow("reminderStartDateTime") {
                $0.hidden = Condition.function(["timeManagedReminders"], { form in
                    let useTimeManagedReminder = ((form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value ?? false)
                    UserDefaults.set(useTimeManagedReminder: useTimeManagedReminder)
                    return !((form.rowBy(tag: "timeManagedReminders") as? SwitchRow)?.value ?? false)
                })
                $0.title = "Alert Time"
                $0.value = startDate
                $0.onChange { [unowned self] row in
                    self.cancelNotification()
                    
                    if let newDate = row.value {
                        UserDefaults.set(timeManagedReminder: newDate)
                        self.createNotification(date: newDate)
                    }
                }
                }

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
                    if UserDefaults.storeDays > 100 {
                        row.title = "Keep Indefinitely"
                    } else {
                        row.title = "Keep notes for \(UserDefaults.storeDays) days"
                    }
                    row.value = Double(UserDefaults.storeDays)
                    cell.valueLabel!.text = ""
                    cell.stepper.minimumValue = 40.0
                    cell.stepper.maximumValue = 101.0
                }).cellUpdate({ (cell, row) in
                    if(row.value != nil)
                    {
                        cell.valueLabel!.text = ""
                    }
                }).onChange({ (row) in
                    let maxValue = 100
                    let storeDays = UserDefaults.storeDays
                    let newValue = Int(row.value!)
                    
                    if storeDays >= maxValue && newValue == maxValue {
                        let alert = UIAlertController(title: "Delete Notes?", message: "All notes over 100 days old will be deleted. Do you want to proceed?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            UserDefaults.set(storeDays: Int(row.value!))
                            row.value = 100.0
                            row.cell.stepper.value = 100.0
                            row.title = "Keep notes for \(UserDefaults.storeDays) days"
                            row.reload()
                        }))
                        
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                            UserDefaults.set(storeDays: storeDays)
                            row.value = 101.0
                            row.cell.stepper.value = 101.0
                        }))
                        
                        self.present(alert, animated: true)
                    } else {
                        UserDefaults.set(storeDays: Int(row.value!))
                        if row.value != nil {
                            row.cell.valueLabel!.text = ""
                            
                            if UserDefaults.storeDays > 100 {
                                row.title = "Keep Indefinitely"
                            } else {
                                row.title = "Keep notes for \(UserDefaults.storeDays) days"
                            }
                        }
                    }
                })
            <<< SwitchRow(){
                $0.title = "Order in ascending order"
                $0.value = UserDefaults.sortOrder
                $0.onChange { row in
                    if let newValue = row.value {
                        print(newValue)
                        UserDefaults.set(sortOrder: newValue)
                    }
                }
            }
            <<< TextRow() {
                $0.title = "Edit Header Name"
                $0.value = UserDefaults.mainTitle
                $0.onChange { row in
                    if let newTitle = row.value {
                        UserDefaults.set(mainTitle: newTitle)
                    }
                }
            }
            
            +++ Section("GET IN TOUCH")
            <<< LabelRow(){ row in
                row.title = "Send us a message"
                }.onCellSelection({ (cell, row) in
                    self.sendEmail()
                })
            
            +++ Section("Account")
            <<< ButtonRow(){ row in
                row.title = "General"
                row.presentationMode = .segueName(segueName: "showGeneral", onDismiss: nil)
            }
            <<< ButtonRow(){ row in
                row.title = "Change Email Account"
                row.presentationMode = .segueName(segueName: "showChangeEmail", onDismiss: nil)
            }
            <<< ButtonRow(){ row in
                row.title = "Change Password"
                row.presentationMode = .segueName(segueName: "showChangePassword", onDismiss: nil)
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Delete Account"
                $0.selectorTitle = "Are you sure you want to delete your account?"
                $0.options = ["No", "Yes"]
                $0.onChange({ [unowned self] row in
                    if let value = row.value {
                        if value == "Yes" {
                            // Delete account
                            let user = Auth.auth().currentUser

                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            user?.delete(completion: { (error) in
                                if error != nil {
                                    SVProgressHUD.showError(withStatus: "Could not delete your user")
                                } else {
                                    self.deleteEmployees()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }).cellUpdate({ (cell, row) in
                    if(row.value != nil)
                    {
                        cell.detailTextLabel?.text = ""
                    }
                    if let value = row.value {
                        if value == "Yes" {
                            // Delete account
                            let user = Auth.auth().currentUser
                            
                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            user?.delete(completion: { (error) in
                                if error != nil {
                                    SVProgressHUD.showError(withStatus: "Could not delete your user")
                                } else {
                                    self.deleteEmployees()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                })
            }
            <<< LabelRow(){ row in
                row.title = "Logout"
                }.onCellSelection({ (cell, row) in
                    print("Logout")
                    do {
                        try Auth.auth().signOut()
                        self.dismiss(animated: true, completion: nil)
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                })
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
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
        var message = ""

        if getNotificationTextCount() == 0 {
            message = "Keep up the great work!"
        } else if getNotificationTextCount() == 1 {
            message = "You have people who need recognition"
        }
        
        //adding title, subtitle, body and badge
        content.title = message
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
    
    private func getNotificationTextCount() -> Int {
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local

        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.reminderStartDays - 1, to: dateFrom)
        var counter = 0
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            FirebaseManager.shared.getEmployees(uid: UserDefaults.userUID) { (results, error) in
                if error != nil {
                } else {
                    for member in results.members {
                        if member.comments.count == 0 {
                            counter += 1
                        }
                        
                        if let latest = member.latest {
                            if latest <= dateTo! {
                                counter += 1
                            }
                        }
                    }
                }
            }
        }

        group.wait()
        
        return counter
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        // Add in the update here
        let date = UserDefaults.timeManagedReminder
        let calendar = Calendar.current
        
        let objectToSave = [
            "First_Name": UserDefaults.userFirstName,
            "Last_Name": UserDefaults.userLastName,
            "Email": UserDefaults.userEmail,
            "Phone": UserDefaults.userPhone,
            "Company": UserDefaults.userCompany,
            "Number_of_People": UserDefaults.userAmount,
            "New": true,
            "UserId": UserDefaults.userUID,
            "isOrderAscending": UserDefaults.sortOrder,
            "headerName": UserDefaults.mainTitle,
            "storeDays": UserDefaults.storeDays,
            "reminderStartDay": UserDefaults.reminderStartDays,
            "isReminder": UserDefaults.useTimeManagedReminder,
            "reminderHours": calendar.component(.hour, from: date!),
            "reminderMinutes": calendar.component(.minute, from: date!)
        ] as [String : Any]
        
        FirebaseManager.shared.updateSettings(uid: UserDefaults.userUID, data: objectToSave) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Could not update settings")
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let body = """
            <p>Name: \(UserDefaults.userFirstName) \(UserDefaults.userLastName)<br>
                Company: \(UserDefaults.userCompany)<br>
                Phone: \(UserDefaults.userPhone)<br>
                Email: \(UserDefaults.userEmail)</p>

                <p>Message: </p>
            """
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@myemployees.com"])
            mail.setSubject("Rise App Message - \(UserDefaults.userEmail)")
            mail.setMessageBody(body, isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            SVProgressHUD.showError(withStatus: "Message could not be sent.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func deleteEmployees() {
        FirebaseManager.shared.getEmployees(uid: UserDefaults.userUID) { (results, error) in
            if error != nil {
                
            } else {
                FirebaseManager.shared.deleteEmployeesBatch(data: results.members) { (error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) { }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
}
