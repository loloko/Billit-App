//
//  DebitTableViewCell.swift
//  Billit
//
//  Created by Fernando Rauber on 22/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class DebtTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbDebitorName: UILabel!
    @IBOutlet weak var lbCreditorName: UILabel!
    
    @IBOutlet weak var lbAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
