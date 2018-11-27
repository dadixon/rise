//
//  ForgotPasswordViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emailTextField: RiseTextField!
    @IBOutlet weak var submitBtn: RisePrimaryUIButton!
    @IBOutlet weak var cancelBtn: RiseSecondaryUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        infoLabel.text = "Enter your email"
        emailTextField.placeholder = "Email"
        submitBtn.setTitle("Submit", for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
    }
    

    @IBAction func submitPressed(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            SVProgressHUD.showError(withStatus: "Please enter an email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                SVProgressHUD.showInfo(withStatus: "Email has been sent to reset your password")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
