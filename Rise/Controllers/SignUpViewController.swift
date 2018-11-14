//
//  SignUpViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 11/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Step 1 of 2"
    }

    @IBAction func continuePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegister", sender: self)
    }
}
