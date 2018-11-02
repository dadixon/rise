//
//  RiseTextView.swift
//  Rise
//
//  Created by Domonique Dixon on 11/2/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import ChameleonFramework

class RiseTextView: UITextView {

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

}

extension RiseTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.layer.borderColor = focusColor.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.layer.borderColor = blurColor.cgColor
    }
}
