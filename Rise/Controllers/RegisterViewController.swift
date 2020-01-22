//
//  RegisterViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: RiseTextField!
    @IBOutlet weak var passwordTextField: RiseTextField!
    @IBOutlet weak var confirmTextField: RiseTextField!
    @IBOutlet weak var signUpBtn: RisePrimaryUIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        title = "Step 2 of 2"
    }

    private func setup() {
        title = "Step 2 of 2"
        
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        confirmTextField.placeholder = "Confirm Password"
        signUpBtn.setTitle("Sign Up", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    private func registerUser(email: String, password: String) {
        ref = Database.database().reference()
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    } else {
                        guard let user = authResult?.user else { return }
                        
                        self.saveUserData(user: user)
                        self.performSegue(withIdentifier: "showList", sender: nil)
                    }
                })
            }
        }
    }
    
    private func saveUserData(user: Firebase.User) {
        ref = Database.database().reference()
        
        let userDefaults = UserDefaults.standard
        
        UserDefaults.set(userUID: user.uid)
        UserDefaults.set(userFirstName: userDefaults.string(forKey: "tempFirstName") ?? "")
        UserDefaults.set(userLastName: userDefaults.string(forKey: "tempLastName") ?? "")
        UserDefaults.set(userPhone: userDefaults.string(forKey: "tempPhone") ?? "")
        UserDefaults.set(userCompany: userDefaults.string(forKey: "tempCompany") ?? "")
        UserDefaults.set(userEmail: user.email!)
        UserDefaults.set(userAmount: userDefaults.string(forKey: "tempAmountOfPeople") ?? "")
        UserDefaults.set(userIsNew: true)
        
        let objectToSave: [String : Any] = [
            "Date": [".sv": "timestamp"],
            "First_Name": UserDefaults.userFirstName,
            "Last_Name": UserDefaults.userLastName,
            "Email": user.email!,
            "Phone": UserDefaults.userPhone,
            "Company": UserDefaults.userCompany,
            "Number_of_People": UserDefaults.userAmount,
            "New": true
        ]
        
        self.ref.child("clients").child(user.uid).setValue(objectToSave) { (error, ref) -> Void in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter an email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a password")
            return
        }
        
        guard let confirm = confirmTextField.text, !confirm.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter a confirm password")
            return
        }
        
        if password != confirm {
            SVProgressHUD.showError(withStatus: "Passwords do not match")
            return
        }
        
        registerUser(email: email, password: confirm)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
