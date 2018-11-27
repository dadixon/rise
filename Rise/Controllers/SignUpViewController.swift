//
//  SignUpViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: RiseTextField!
    @IBOutlet weak var lastNameTextField: RiseTextField!
    @IBOutlet weak var phoneTextField: RiseTextField!
    @IBOutlet weak var companyTextField: RiseTextField!
    @IBOutlet weak var numberOfStaffTextField: RiseTextField!
    
    @IBOutlet weak var continueBtn: RisePrimaryUIButton!
    @IBOutlet weak var loginBtn: RiseSecondaryUIButton!
    
    var ref: DatabaseReference!
    var amountOfPeoplePickList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Step 1 of 2"
        
        setup()
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        firstNameTextField.placeholder = "First Name"
        lastNameTextField.placeholder = "Last Name"
        phoneTextField.placeholder = "Phone Number"
        companyTextField.placeholder = "Company"
        
        amountOfPeoplePickList = ["Less than 25 \(UserDefaults.mainTitle)", "25-50", "51-75", "76-100"]
        let amountPicker = UIPickerView()
        amountPicker.delegate = self
        
        numberOfStaffTextField.delegate = self
        numberOfStaffTextField.text = amountOfPeoplePickList[0]
        numberOfStaffTextField.inputView = amountPicker
        
        continueBtn.setTitle("Continue", for: .normal)
        loginBtn.setTitle("Already have an acount? Login", for: .normal)
    }
    
    private func saveUserData(firstName: String, lastName: String, phone: String, company: String, amountOfPeople: String) {
        UserDefaults.set(userFirstName: firstName)
        UserDefaults.set(userLastName: lastName)
        UserDefaults.set(userPhone: phone)
        UserDefaults.set(userCompany: company)
        UserDefaults.set(userAmount: amountOfPeople)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a first name")
            return
        }

        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a last name")
            return
        }

        guard let phone = phoneTextField.text, !phone.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a phone number")
            return
        }

        guard let company = companyTextField.text, !company.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a company name")
            return
        }

        guard let amountOfPeople = numberOfStaffTextField.text, !amountOfPeople.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter an amount of \(UserDefaults.mainTitle)")
            return
        }
        
        saveUserData(firstName: firstName, lastName: lastName, phone: phone, company: company, amountOfPeople: amountOfPeople)
        self.performSegue(withIdentifier: "showRegister", sender: self)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return amountOfPeoplePickList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return amountOfPeoplePickList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfStaffTextField.text = amountOfPeoplePickList[row]
    }
}

extension SignUpViewController: UIPickerViewDataSource {
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
