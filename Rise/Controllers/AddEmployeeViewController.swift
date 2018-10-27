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

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addEmployeeBtn: UIButton!
    @IBOutlet weak var addMoreBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        firstNameTextField.placeholder = "First Name"
        lastNameTextField.placeholder = "Last Name"
        addEmployeeBtn.setTitle("Save Employee", for: .normal)
        addMoreBtn.setTitle("Save and Add Another", for: .normal)
    }
    
    @IBAction func addEmployeeClicked(_ sender: Any) {
        // Save Employee
        saveEmployee()
        
        // Go back to previous view
        performSegue(withIdentifier: "unwindToEmployeesDashboard", sender: self)
    }
    
    @IBAction func addMoreEmployeeClicked(_ sender: Any) {
        // Save Employee
        saveEmployee()
        
        //Clear textfields
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        
        firstNameTextField.becomeFirstResponder()
    }
    
    func saveEmployee() {
        let employee = Employee(context: context)
        
        guard let firstName = firstNameTextField.text else {
            SVProgressHUD.showError(withStatus: "Please give a first name")
            return
        }
        
        guard let lastName = lastNameTextField.text else {
            SVProgressHUD.showError(withStatus: "Please give a last name")
            return
        }
        
        employee.firstName = firstName
        employee.lastName = lastName
        
        do {
            try context.save()
            print("saved")
        } catch {
            SVProgressHUD.showError(withStatus: "Error saving item")
            print("Error saving context \(error)")
        }
    }
}
