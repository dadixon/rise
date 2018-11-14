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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "showList", sender: nil)
                SVProgressHUD.dismiss()
            }
        })
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showSignUp", sender: self)
    }
}
