//
//  TableViewCellAmount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/29.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCellAmount: UITableViewCell {

    @IBOutlet weak var label_amount_previous: UILabel!
    @IBOutlet weak var label_amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
