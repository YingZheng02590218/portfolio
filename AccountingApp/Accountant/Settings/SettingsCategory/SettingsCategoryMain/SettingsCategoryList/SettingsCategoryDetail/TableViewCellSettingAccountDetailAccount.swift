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
            textField_AccountDetail_Account.textColor = .lightGray // 文字色をグレーアウトとする
        }
        self.endEditing(true)
    }
    
    @objc func cancel() {
        self.textField_AccountDetail_Account.text = ""
        self.endEditing(true)
    }
    // textFieldに文字が入力される際に呼ばれる　入力チェック(文字列、文字数制限)
    // 戻り値にtrueを返すと入力した文字がTextFieldに反映され、falseを返すと入力した文字が反映されない。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var resultForCharacter = false
        var resultForLength = false
        // 入力チェック　カンマを除外
        if textField == textField_AccountDetail_Account { // 勘定科目名
            let notAllowedCharacters = CharacterSet(charactersIn:",")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            // 指定したスーパーセットの文字セットでないならfalseを返す
            resultForCharacter = !(notAllowedCharacters.isSuperset(of: characterSet))
            // 入力チェック　文字数最大数を設定
            let maxLength: Int = 20 // 文字数最大値を定義
            // textField内の文字数
            let textFieldNumber = textField.text?.count ?? 0    //todo
            // 入力された文字数
            let stringNumber = string.count
            // 最大文字数以上ならfalseを返す
            resultForLength = textFieldNumber + stringNumber < maxLength
            // 文字列が0文字の場合、backspaceキーが押下されたということなので一文字削除する
            if(string == "") {
                textField.deleteBackward()
            }
        }
        // 判定
        if !resultForCharacter { // 指定したスーパーセットの文字セットならfalseを返す
            return false
        }else if !resultForLength { // 最大文字数以上ならfalseを返す
            return false
        }else {
            return true
        }
    }
    //リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)

        return false
    }
}
