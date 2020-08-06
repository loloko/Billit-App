//
//  SettingsCell.swift
//  Billit
//
//  Created by Fernando Rauber on 24/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
