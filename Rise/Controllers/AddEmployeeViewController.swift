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

    @IBOutlet weak var fullNameTextField: RiseTextField!
    @IBOutlet weak var addEmployeeBtn: UIButton!
    @IBOutlet weak var addMoreBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        do {
            // Save Employee
             try saveEmployee()
            
            // Go back to previous view
            performSegue(withIdentifier: "unwindToEmployeesDashboard", sender: self)
        } catch ErrorsToThrow.fullNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a full name")
            fullNameTextField.becomeFirstResponder()
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
            fullNameTextField.text = ""
            
            fullNameTextField.becomeFirstResponder()
        } catch ErrorsToThrow.fullNameNotFound {
            SVProgressHUD.showError(withStatus: "Please give a full name")
        } catch ErrorsToThrow.canNotSave {
            SVProgressHUD.showError(withStatus: "Error saving item")
        } catch {
            
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func saveEmployee() throws {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            throw ErrorsToThrow.fullNameNotFound
        }
        
        let employee = Employee(context: context)
        employee.fullName = fullName
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
