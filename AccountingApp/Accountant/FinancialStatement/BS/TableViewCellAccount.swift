//
//  TableViewCellAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCellAccount: UITableViewCell {

    @IBOutlet weak var label_account_previous: UILabel!
    @IBOutlet weak var label_account: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
