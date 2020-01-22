//
//  LoginViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/5/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: RiseTextField!
    @IBOutlet weak var passwordTextField: RiseTextField!
    @IBOutlet weak var loginBtn: RisePrimaryUIButton!
    @IBOutlet weak var signUpBtn: RiseSecondaryUIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        loginBtn.setTitle("Login", for: .normal)
        signUpBtn.setTitle("Don't have an account? Sign-up", for: .normal)
        forgotPasswordBtn.setTitle("Forgot Password? Click Here", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEmployeeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                guard let user = authResult?.user else { return }
                
                UserDefaults.set(userUID: user.uid)
                self.setGeneralData()
                self.performSegue(withIdentifier: "showList", sender: nil)
                SVProgressHUD.dismiss()
            }
        })
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showForgotPassword", sender: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func setGeneralData() {
        let ref = Database.database().reference()
        ref.child("clients").child(UserDefaults.userUID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let values = snapshot.value as? [String: Any] else {
                return
            }
            
            let value = snapshot.value as? NSDictionary
            let firstName = value?["First_Name"] as? String ?? ""
            let lastName = value?["Last_Name"] as? String ?? ""
            let phone = value?["Phone"] as? String ?? ""
            let company = value?["Company"] as? String ?? ""
            let email = value?["Email"] as? String ?? ""
            let amountOfPeople = value?["Number_of_People"] as? String ?? ""
            let createdDate = (value?["Date"] as? Int)!
            let newUser = (value?["New"] as? Bool)!
            
            UserDefaults.set(userFirstName: firstName)
            UserDefaults.set(userLastName: lastName)
            UserDefaults.set(userPhone: phone)
            UserDefaults.set(userCompany: company)
            UserDefaults.set(userEmail: email)
            UserDefaults.set(userAmount: amountOfPeople)
            UserDefaults.set(userCreatedDate: createdDate)
            UserDefaults.set(userIsNew: newUser)

        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
