//
//  CourseDetailList_TableViewCell.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 1/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

class courseItems_cell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
