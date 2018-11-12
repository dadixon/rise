//
//  EmployeeTableViewCell.swift
//  Rise
//
//  Created by Domonique Dixon on 9/13/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var noteCountLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let mScreenSize = UIScreen.main.bounds
        let mSeparatorHeight = CGFloat(8.0) // Change height of speatator as you want
        let mAddSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height - mSeparatorHeight, width: mScreenSize.width, height: mSeparatorHeight))
        mAddSeparator.backgroundColor = UIColor.white
        self.addSubview(mAddSeparator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
