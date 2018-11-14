//
//  RegisterViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Step 2 of 2"
    }

    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showList", sender: self)
    }
}
