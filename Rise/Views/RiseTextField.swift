//
//  RiseTextField.swift
//  Rise
//
//  Created by Domonique Dixon on 10/29/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import ChameleonFramework

class RiseTextField: UITextField {

    var focusColor = UIColor()
    var blurColor = UIColor()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        
        focusColor = HexColor("99FBDA")!
        blurColor = HexColor("6F6F6F")!
        
        self.layer.borderColor = blurColor.cgColor
        self.layer.borderWidth = 1.5
        self.layer.masksToBounds = true
    }
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension RiseTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.layer.borderColor = focusColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderColor = blurColor.cgColor
    }
}
