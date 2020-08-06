//
//  BillFriendTableViewCell.swift
//  Billit
//
//  Created by Fernando Rauber on 18/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class BillFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var tfPaid: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
