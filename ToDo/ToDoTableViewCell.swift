//
//  ToDoTableViewCell.swift
//  ToDo
//
//  Created by Ankur Jain on 09/05/16.
//  Copyright © 2016 Tanisha. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var task: UILabel!
    
    @IBOutlet weak var check: UIView!
  
    @IBOutlet weak var tick: UIImageView!
    
    @IBOutlet weak var line: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
