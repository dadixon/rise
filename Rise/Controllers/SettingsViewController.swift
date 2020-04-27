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
    var data: DataModel?
    
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
        
        if UserDefaults.useTimeManagedReminder {
            startDate = UserDefaults.timeManagedReminder
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
                    $0.onChange{ row in
                        UserDefaults.set(useTimeManagedReminder: row.value!)
                        
                        if UserDefaults.useTimeManagedReminder {
                            Notifications.shared.registerNotification()
                        } else {
                            Notifications.shared.cancelNotification()
                        }
                    }
                }
                <<< TimeRow("reminderStartDateTime") {
                    $0.hidden = Condition.function(["timeManagedReminders"], { form in
                        return !UserDefaults.useTimeManagedReminder
                    })
                    $0.title = "Alert Time"
                    $0.value = UserDefaults.timeManagedReminder
                    $0.onChange { row in
                        let values = self.form.values()
                        
                        UserDefaults.set(timeManagedReminder: values["reminderStartDateTime"] as! Date)
                    }
                }
            <<< StepperRow("reminderDays"){
                $0.title = "Days before reminders"
                $0.value = Double(UserDefaults.reminderStartDays)
                $0.cell.stepper.stepValue = 1
                $0.displayValueFor = { value in
                    guard let value = value else { return nil }
                    return "\(Int(value))"
                }
                $0.cell.stepper.minimumValue = 0
                $0.cell.stepper.maximumValue = 100
            }.onChange({ (row) in
                let values = self.form.values()
                UserDefaults.set(reminderStartDays: Int(values["reminderDays"] as! Double))
            })
            
            +++ Section("General")
            <<< StepperRow("storeDays"){
                if UserDefaults.storeDays > 100 {
                    $0.title = "Keep Indefinitely"
                } else {
                    $0.title = "Keep notes for \(UserDefaults.storeDays) days"
                }
                $0.value = Double(UserDefaults.storeDays)
                $0.cell.stepper.stepValue = 1
                $0.displayValueFor = { value in
                    guard let value = value else { return nil }
                    return "\(Int(value))"
                }
                $0.cell.stepper.minimumValue = 40
                $0.cell.stepper.maximumValue = 101
            }.onChange({ row in
                let values = self.form.values()
                let newValue = Int(values["storeDays"] as! Double)
                let maxValue = 100
                let storeDays = UserDefaults.storeDays
                let r = self.form.rowBy(tag: "storeDays")
                
                if storeDays >= maxValue && newValue == maxValue {
                    let alert = UIAlertController(title: "Delete Notes?", message: "All notes over 100 days old will be deleted. Do you want to proceed?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        UserDefaults.set(storeDays: newValue)
                        row.value = 100.0
                        row.cell.stepper.value = 100.0
                        r?.title = "Keep notes for \(UserDefaults.storeDays) days"
                        r?.reload()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                        UserDefaults.set(storeDays: storeDays)
                        row.value = 101.0
                        row.cell.stepper.value = 101.0
                    }))
                    
                    self.present(alert, animated: true)
                } else {
                    UserDefaults.set(storeDays: newValue)
                    if row.value != nil {
                        row.cell.valueLabel!.text = ""
                        
                        if UserDefaults.storeDays > 100 {
                            r?.title = "Keep Indefinitely"
                        } else {
                            r?.title = "Keep notes for \(UserDefaults.storeDays) days"
                        }
                        r?.updateCell()
                    }
                }
            })
            
            
            <<< SwitchRow(){
                $0.title = "Order in ascending order"
                $0.value = UserDefaults.sortOrder
                $0.onChange { row in
                    if let newValue = row.value {
                        UserDefaults.set(sortOrder: newValue)
                    }
                }
            }
            <<< TextRow("mainTitle") {
                $0.title = "Edit Header Name"
                $0.value = UserDefaults.mainTitle
                $0.onChange { row in
                    let values = self.form.values()
                    let newValue = values["mainTitle"] as! String

                    UserDefaults.set(mainTitle: newValue)
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
                $0.onChange { (row) in
                    if let value = row.value {
                        if value == "Yes" {
                            // Delete account
                            let user = Auth.auth().currentUser

                            self.deleteEmployees()
                            self.deleteSettings()
                            
                            user?.delete(completion: { (error) in
                                if error != nil {
                                    SVProgressHUD.showError(withStatus: "Could not delete your user")
                                } else {
                                    do {
                                        try Auth.auth().signOut()
                                        self.dismiss(animated: true, completion: nil)
                                    } catch let signOutError as NSError {
                                        print ("Error signing out: %@", signOutError)
                                    }
                                }
                            })
                        }
                    }
                }
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
    
    @IBAction func dismissPressed(_ sender: Any) {
        setNotifications()
        saveSettings()
    }
    
    private func saveSettings() {
        let date = UserDefaults.timeManagedReminder
        let calendar = Calendar.current
        let objectToSave = [
            "First_Name": UserDefaults.userFirstName,
            "Last_Name": UserDefaults.userLastName,
            "Email": UserDefaults.userEmail,
            "Phone": UserDefaults.userPhone,
            "Company": UserDefaults.userCompany,
            "Number_of_People": UserDefaults.userAmount,
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
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func setNotifications() {
        Notifications.shared.cancelNotification()
        
        if UserDefaults.useTimeManagedReminder {
            Notifications.shared.createNotification(date: UserDefaults.timeManagedReminder!)
        }
    }
    
    private func sendEmail() {
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
                print(error?.localizedDescription)
            } else {
                FirebaseManager.shared.deleteEmployeesBatch(data: results.members) { (error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func deleteSettings() {
        FirebaseManager.shared.deleteSettings(uid: UserDefaults.userUID) { (error) in
            if error != nil {
                print("Error \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) { }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
}
