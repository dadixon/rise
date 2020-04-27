//
//  GeneralViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/27/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import SVProgressHUD

class GeneralViewController: FormViewController {

    var firstName: String = ""
    var lastName: String = ""
    var company: String = ""
    var phone: String = ""
    var amountOfPeople: String = ""
    var email: String = ""
    var createdDate = NSNumber()
    var newUser = Bool()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGeneralData()
        
        navigationItem.largeTitleDisplayMode = .never
        
        form
            +++ Section()
            <<< TextRow(){
                $0.title = "First Name"
                $0.value = UserDefaults.userFirstName
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    if (row.value != nil) {
                        self.firstName = row.value!
                    }
                })
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                        self.firstName = ""
                    }
                }
            <<< TextRow(){
                $0.title = "Last Name"
                $0.value = UserDefaults.userLastName
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    if (row.value != nil) {
                        self.lastName = row.value!
                    }
                })
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                        self.lastName = ""
                    }
                }
            <<< PhoneRow(){
                $0.title = "Phone"
                $0.value = UserDefaults.userPhone
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    if (row.value != nil) {
                        self.phone = row.value!
                    }
                })
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                        self.phone = ""
                    }
                }
            <<< TextRow(){
                $0.title = "Company"
                $0.value = UserDefaults.userCompany
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    if (row.value != nil) {
                        self.company = row.value!
                    }
                })
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                        self.company = ""
                    }
                }
            <<< PushRow<String>(){
                $0.title = "Employees"
                $0.options = ["Less than 25", "25-50", "51-75", "76-100", "100+"]
                $0.value = UserDefaults.userAmount
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    if (row.value != nil) {
                        self.amountOfPeople = row.value!
                    }
                })
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                        self.amountOfPeople = ""
                    }
                }
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                }
                .onCellSelection ({ [unowned self] (cell, row) in
                    self.saveGeneralData()
                    self.performSegue(withIdentifier: "unwindToSettings", sender: self)
                })
    }
    
    private func getGeneralData() {
        self.firstName = UserDefaults.userFirstName
        self.lastName = UserDefaults.userLastName
        self.phone = UserDefaults.userPhone
        self.company = UserDefaults.userCompany
        self.amountOfPeople = UserDefaults.userAmount
    }
    
    private func saveGeneralData() {
        guard self.firstName != "" else {
            SVProgressHUD.showError(withStatus: "Please enter a first name")
            return
        }

        guard self.lastName != "" else {
            SVProgressHUD.showError(withStatus: "Please enter a last name")
            return
        }

        guard self.phone != "" else {
            SVProgressHUD.showError(withStatus: "Please enter a phone number")
            return
        }

        guard self.company != "" else {
            SVProgressHUD.showError(withStatus: "Please enter a company name")
            return
        }

        guard self.amountOfPeople != "" else {
            SVProgressHUD.showError(withStatus: "Please select an amount")
            return
        }

        UserDefaults.set(userFirstName: firstName)
        UserDefaults.set(userLastName: lastName)
        UserDefaults.set(userPhone: phone)
        UserDefaults.set(userCompany: company)
        UserDefaults.set(userAmount: amountOfPeople)
    }
}
