//
//  NoteTableViewCell.swift
//  Rise
//
//  Created by Domonique Dixon on 9/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
