//
//  TableViewCellCompanyName.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewCellCompanyName: UITableViewCell, UITextViewDelegate { //プロトコルを追加

    @IBOutlet var textView_companyName: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // デリゲートを設定
        textView_companyName.delegate = self
        // データベース
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf() //データベースマネジャー
        let company = dataBaseManagerAccountingBooksShelf.getCompanyName()
        textView_companyName.text = company // 事業者名
        textView_companyName.textContainer.lineBreakMode = .byTruncatingTail //文字が入りきらない場合に行末を…にしてくれます
        textView_companyName.textContainer.maximumNumberOfLines = 1 //最大行数を1行に制限
        textView_companyName.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
    }
    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return false
//    }
//    func textViewDidBeginEditing(_ textView: UITextView) {//
//    }
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        return false
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("")
        // データベース
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf() //データベースマネジャー
        dataBaseManagerAccountingBooksShelf.updateCompanyName(companyName: textView.text)
    }
    // 入力制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 入力を反映させたテキストを取得する
        let resultText: String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        var resultForCharacter = false
        var resultForLength = false
        let notAllowedCharacters = CharacterSet(charactersIn:",\("\n")")//カンマ、改行
        let characterSet = CharacterSet(charactersIn: text)
        // 指定したスーパーセットの文字セットでないならfalseを返す
        resultForCharacter = !(notAllowedCharacters.isSuperset(of: characterSet))
        // 入力チェック　文字数最大数を設定
        let maxLength: Int = 20 // 文字数最大値を定義
        // textField内の文字数
        let textFieldNumber = resultText.count    //todo
        print(resultText.count)
        // 入力された文字数
        let stringNumber = text.count
        print(text.count)
        // 最大文字数以上ならfalseを返す
        resultForLength = textFieldNumber + stringNumber < maxLength
        // 文字列が0文字の場合、backspaceキーが押下されたということなので一文字削除する
        if(text == "") {
            self.textView_companyName.deleteBackward()
        }
        // 改行が入力された場合、リターンキーが押下されたということなのでキーボードを閉じる
        if(text == "\n") {
            textView.resignFirstResponder()
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
    
}
