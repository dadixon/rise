//
//  AddEmployeeViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/13/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddEmployeeViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: RiseTextField!
    @IBOutlet weak var addEmployeeBtn: UIButton!
    @IBOutlet weak var addMoreBtn: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        fullNameTextField.placeholder = "Full Name"
        addEmployeeBtn.setTitle("Save", for: .normal)
        addMoreBtn.setTitle("Save and Add Another", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEmployeeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        
        fullNameTextField.becomeFirstResponder()
    }
    
    @IBAction func addEmployeeClicked(_ sender: Any) {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please give a full name")
            fullNameTextField.becomeFirstResponder()
            return
        }
        
        CoreDataManager.shared.insertEmployee(name: fullName, userID: UserDefaults.userUID) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Error saving item")
            } else {
                self.performSegue(withIdentifier: "unwindToEmployeesDashboard", sender: self)
            }
        }
    }
    
    @IBAction func addMoreEmployeeClicked(_ sender: Any) {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please give a full name")
            return
        }
        
        CoreDataManager.shared.insertEmployee(name: fullName, userID: UserDefaults.userUID) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Error saving item")
            }
        }
            
        fullNameTextField.text = ""
        fullNameTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
//    func saveEmployee() throws {
//        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
//            throw ErrorsToThrow.fullNameNotFound
//        }
//
//        let employee = Employee(context: context)
//        employee.fullName = fullName
//        employee.latest = nil
//        employee.userId = UserDefaults.userUID
//
//        do {
//            try context.save()
//            print("saved")
//        } catch {
//            print("Error saving context \(error)")
//            throw ErrorsToThrow.canNotSave
//        }
//    }
}
