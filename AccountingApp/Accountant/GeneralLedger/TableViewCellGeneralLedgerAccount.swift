//
//  TableViewCellGeneralLedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCellGeneralLedgerAccount: UITableViewCell {

    @IBOutlet weak var label_list_date_month: UILabel!
    @IBOutlet weak var label_list_date_day: UILabel!
    @IBOutlet weak var label_list_summary: UILabel!
    @IBOutlet weak var label_list_number: UILabel!
    @IBOutlet weak var label_list_debit: UILabel!
    @IBOutlet weak var label_list_credit: UILabel!
    @IBOutlet weak var label_list_debitOrCredit: UILabel!
    @IBOutlet weak var label_list_balance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
