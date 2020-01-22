//
//  ChangePasswordViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/27/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import SVProgressHUD

class ChangePasswordViewController: FormViewController {

    var password: String = ""
    var confirmedPassword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        form
            +++ Section()
            <<< PasswordRow(){
                $0.title = "New Password"
                }.onChange({ (row) in
                    self.password = row.value!
                })
            
            <<< PasswordRow(){
                $0.title = "Confirm New Password"
                }.onChange({ (row) in
                    self.confirmedPassword = row.value!
                })
            
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                }
                .onCellSelection ({ [unowned self] (cell, row) in
                    if self.password == self.confirmedPassword {
                        let user = Auth.auth().currentUser
                        
                        user?.updatePassword(to: self.confirmedPassword) { (error) in
                            if let error = error {
                                if let errCode = AuthErrorCode(rawValue: error._code) {
                                    switch errCode {
                                    case .requiresRecentLogin:
                                        self.performSegue(withIdentifier: "showReLogin", sender: self)
                                    default:
                                        print(error._code)
                                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                                    }
                                }
                            } else {
                                SVProgressHUD.showInfo(withStatus: "Password Updated")
                            }
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "Passwords do not match")
                    }
                })
    }
}
