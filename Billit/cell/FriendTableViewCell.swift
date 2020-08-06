//
//  FriendTableViewCell.swift
//  Billit
//
//  Created by Fernando Rauber on 16/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var tfPaid: UITextField!
    @IBOutlet weak var lbPaid: UILabel!
    
    @IBOutlet weak var vBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
}
