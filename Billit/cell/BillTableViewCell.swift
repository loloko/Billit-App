//
//  BillTableViewCell.swift
//  Billit
//
//  Created by Fernando Rauber on 21/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbFriends: UILabel!
    @IBOutlet weak var lbDebsCount: UILabel!
    @IBOutlet weak var lbOwnerName: UILabel!
    @IBOutlet weak var lbAccessCode: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
