//
//  ChangeEmailViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/21/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import SVProgressHUD

class ChangeEmailViewController: FormViewController {
    
    var email: String = ""
    var confirmedEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        form
            +++ Section()
            <<< EmailRow(){
                $0.title = "New Email"
                }.onChange({ (row) in
                    self.email = row.value!
                })
            
            <<< EmailRow(){
                $0.title = "Confirm New Email"
                }.onChange({ (row) in
                    self.confirmedEmail = row.value!
                })
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                }
                .onCellSelection ({ [unowned self] (cell, row) in
                    if self.email == self.confirmedEmail {
                        let user = Auth.auth().currentUser
                        
                        user?.updateEmail(to: self.confirmedEmail) { (error) in
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
                                
                                let objectToSave = [
                                    "Email": self.confirmedEmail
                                ] as [String : Any]
                                
                                FirebaseManager.shared.updateSettings(uid: UserDefaults.userUID, data: objectToSave) { (error) in
                                    if error != nil {
                                        SVProgressHUD.showError(withStatus: "Could not update settings")
                                    } else {
                                        UserDefaults.set(userEmail: self.confirmedEmail)
                                        SVProgressHUD.showSuccess(withStatus: "Email Updated")
                                        
                                    }
                                }
                            }
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "Emails do not match")
                    }
            })
    }
}
