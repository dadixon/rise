//
//  ReLoginViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/23/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ReLoginViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameTextField: RiseTextField!
    @IBOutlet weak var passwordTextField: RiseTextField!
    @IBOutlet weak var loginBtn: RisePrimaryUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = "Have to login to change data"
        usernameTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        loginBtn.setTitle("Login", for: .normal)
    }
    
    private func reauthenticate(username: String, password: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: username, password: password)
        
        user?.reauthenticateAndRetrieveData(with: credential, completion: { (data, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let username = usernameTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        self.reauthenticate(username: username, password: password)
    }
}
