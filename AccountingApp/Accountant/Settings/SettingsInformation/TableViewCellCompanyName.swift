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
        print("")
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
        if resultText.count <= 30 { // 文字数制限
            return true
        }
        return false
    }
}
