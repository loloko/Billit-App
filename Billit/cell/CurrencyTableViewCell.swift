//
//  CurrencyTableViewCell.swift
//  Billit
//
//  Created by Fernando Rauber on 22/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

final class CurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbCountry: UILabel!
    @IBOutlet weak var lbCurrency: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
