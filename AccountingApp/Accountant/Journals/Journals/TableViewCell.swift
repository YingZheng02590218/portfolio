//
//  TableViewCell.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var label_list_summary_debit: UILabel!
    @IBOutlet weak var label_list_summary_credit: UILabel!
    @IBOutlet weak var label_list_summary: UILabel!
    @IBOutlet weak var label_list_date_month: UILabel!
    @IBOutlet weak var label_list_date: UILabel!
    @IBOutlet weak var label_list_number_left: UILabel!
    @IBOutlet weak var label_list_number_right: UILabel!
    @IBOutlet weak var label_list_debit: UILabel!
    @IBOutlet weak var label_list_credit: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
