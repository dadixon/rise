//
//  AddEmployeeViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/13/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class AddEmployeeViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: RiseTextField!
    @IBOutlet weak var lastNameTextField: RiseTextField!
    @IBOutlet weak var addEmployeeBtn: UIButton!
    @IBOutlet weak var addMoreBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        firstNameTextField.placeholder = "First Name"
        lastNameTextField.placeholder = "Last Name"
        addEmployeeBtn.setTitle("Save Employee", for: .normal)
        addMoreBtn.setTitle("Save and Add Another", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEmployeeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
    }
    
    @IBAction func addEmployeeClicked(_ sender: Any) {
        do {
            // Save Employee
             try saveEmployee()
            
            // Go back to previous view
            performSegue(withIdentifier: "unwindToEmployeesDashboard", sender: self)
        } catch ErrorsToThrow.firstNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a first name")
            firstNameTextField.becomeFirstResponder()
        } catch ErrorsToThrow.lastNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a last name")
            lastNameTextField.becomeFirstResponder()
        } catch ErrorsToThrow.canNotSave {
            SVProgressHUD.showError(withStatus: "Error saving item")
        } catch {
            
        }
    }
    
    @IBAction func addMoreEmployeeClicked(_ sender: Any) {
        do {
            // Save Employee
            try saveEmployee()
            
            //Clear textfields
            firstNameTextField.text = ""
            lastNameTextField.text = ""
            
            firstNameTextField.becomeFirstResponder()
        } catch ErrorsToThrow.firstNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a first name")
        } catch ErrorsToThrow.lastNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a last name")
        } catch ErrorsToThrow.canNotSave {
            SVProgressHUD.showError(withStatus: "Error saving item")
        } catch {
            
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func saveEmployee() throws {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            throw ErrorsToThrow.firstNameNotFound
        }
        
        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            throw ErrorsToThrow.lastNameNotFound
        }
        
        let employee = Employee(context: context)
        employee.firstName = firstName
        employee.lastName = lastName
        employee.latest = nil
        
        do {
            try context.save()
            print("saved")
        } catch {
            print("Error saving context \(error)")
            throw ErrorsToThrow.canNotSave
        }
    }
}
