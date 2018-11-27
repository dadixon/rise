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
                }.onChange({ (row) in
                    self.firstName = row.value!
                })
            
            <<< TextRow(){
                $0.title = "Last Name"
                $0.value = UserDefaults.userLastName
                }.onChange({ (row) in
                    self.lastName = row.value!
                })
            
            <<< PhoneRow(){
                $0.title = "Phone"
                $0.value = UserDefaults.userPhone
                }.onChange({ (row) in
                    self.phone = row.value!
                })
            
            <<< TextRow(){
                $0.title = "Company"
                $0.value = UserDefaults.userCompany
                }.onChange({ (row) in
                    self.company = row.value!
                })
            
            <<< PushRow<String>(){
                $0.title = "\(UserDefaults.mainTitle)s"
                $0.options = ["Less than 25", "25-50", "51-75", "76-100"]
                $0.value = UserDefaults.userAmount
                }.onChange({ (row) in
                    self.amountOfPeople = row.value!
                })
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                }
                .onCellSelection ({ [unowned self] (cell, row) in
                    self.saveGeneralData()
                })
    }
    
    private func getGeneralData() {
        ref = Database.database().reference()
        ref.child("clients").child(UserDefaults.userUID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let values = snapshot.value as? [String: Any] else {
                return
            }

            print(values)
            let value = snapshot.value as? NSDictionary
            self.firstName = value?["First_Name"] as? String ?? ""
            self.lastName = value?["Last_Name"] as? String ?? ""
            self.phone = value?["Phone"] as? String ?? ""
            self.company = value?["Company"] as? String ?? ""
            self.email = value?["Email"] as? String ?? ""
            self.createdDate = (value?["Date"] as? NSNumber)!
            self.newUser = (value?["New"] as? Bool)!

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func saveGeneralData() {
        ref = Database.database().reference()
        
        UserDefaults.set(userFirstName: self.firstName)
        UserDefaults.set(userLastName: self.lastName)
        UserDefaults.set(userPhone: self.phone)
        UserDefaults.set(userCompany: self.company)
        UserDefaults.set(userAmount: self.amountOfPeople)
        
        let userId = Auth.auth().currentUser?.uid
        
        let post: [String : Any] = [
            "UserId": userId as Any,
            "Date": self.createdDate,
            "First_Name": UserDefaults.userFirstName,
            "Last_Name": UserDefaults.userLastName,
            "Email": self.email,
            "Phone": UserDefaults.userPhone,
            "Company": UserDefaults.userCompany,
            "Number_of_People": UserDefaults.userAmount,
            "New": self.newUser
            ]
        let childUpdates = ["/clients/\(UserDefaults.userUID)": post]
        ref.updateChildValues(childUpdates)
    }
}
