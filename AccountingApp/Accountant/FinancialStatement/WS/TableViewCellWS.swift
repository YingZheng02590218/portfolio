//
//  TableViewCellWS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCellWS: UITableViewCell {

    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var label_debit: UILabel!
    @IBOutlet weak var label_credit: UILabel!
    @IBOutlet weak var label_debit1: UILabel!
    @IBOutlet weak var label_credit1: UILabel!
    @IBOutlet weak var label_debit2: UILabel!
    @IBOutlet weak var label_credit2: UILabel!
    @IBOutlet weak var label_debit3: UILabel!
    @IBOutlet weak var label_credit3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
