//
//  TableViewCellSettingAccountDetailAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目詳細セル　テキストフィールド入力　勘定科目名
class TableViewCellSettingAccountDetailAccount: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var textField_AccountDetail_Account: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField_AccountDetail_Account.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:0, height: 44))
        toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)// RGBで指定する alpha 0透明　1不透明
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, flexSpaceItem, doneItem], animated: true)
        // previous, next, paste ボタンを消す
        self.inputAssistantItem.leadingBarButtonGroups.removeAll()

        self.textField_AccountDetail_Account.inputAccessoryView = toolbar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc func done() {
        if textField_AccountDetail_Account!.text == "" {
            textField_AccountDetail_Account!.text = "入力してください"
            textField_AccountDetail_Account.textColor = .lightGray // 文字色をグレーアウトとする
        }
        self.endEditing(true)
    }
    
    @objc func cancel() {
        self.textField_AccountDetail_Account.text = "入力してください"
        self.endEditing(true)
    }
}
