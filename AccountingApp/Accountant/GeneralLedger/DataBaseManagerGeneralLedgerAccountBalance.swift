//
//  DataBaseManagerGeneralLedgerAccountBalance.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 差引残高クラス
class DataBaseManagerGeneralLedgerAccountBalance {
    
    var balanceAmount:Int64 = 0            // 差引残高額
    var balanceDebitOrCredit:String = "" // 借又貸
    var objects:Results<DataBaseJournalEntry>! // 仕訳
    var objectssss:Results<DataBaseAdjustingEntry>! // 決算整理仕訳　繰越利益　資本振替
    var objectss:Results<DataBaseAdjustingEntry>! // 決算整理仕訳　勘定別
    var objectsssss:Results<DataBaseAdjustingEntry>! // 決算整理仕訳　損益勘定　繰越利益を含む

    // 計算　差引残高
    func calculateBalance(account: String) {
        let dataBaseManagerAccount = DataBaseManagerAccount()
        objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account) // 仕訳
        objectssss = dataBaseManagerAccount.getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: account) // 決算整理仕訳　勘定別 損益勘定のみ　繰越利益のみ
        objectss = dataBaseManagerAccount.getAdjustingJournalEntryInAccount(account: account) // 決算整理仕訳　勘定別　注意：損益勘定を含めないとエラーになる
        objectsssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: account) // 決算整理仕訳　勘定別 損益勘定のみ　繰越利益を含む
        var left: Int64 = 0 // 差引残高 累積　勘定内の仕訳データを全て表示するまで、覚えておく
        var right: Int64 = 0
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            print("仕訳", objects.count, objects!)
            for i in 0..<objects.count { // 勘定内のすべての仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(objects[i].debit_category)" { // 借方
                    left += objects[i].debit_amount // 累計額に追加
                }else if account == "\(objects[i].credit_category)" { // 貸方
                    right += objects[i].credit_amount // 累計額に追加
                }
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objects[i].balance_left = left - right // 差額を格納
                    objects[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objects[i].balance_left = 0
                    objects[i].balance_right = right - left
                }else {
                    objects[i].balance_left = 0 // ゼロを入れないと前回値が残る
                    objects[i].balance_right = 0
                }
            }
        }
        try! realm.write {
            print("決算整理仕訳", objectss.count, objectss!)
            for i in 0..<objectss.count { // 勘定内のすべての決算整理仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(objectss[i].debit_category)" { // 借方
                    left += objectss[i].debit_amount // 累計額に追加
                }else if account == "\(objectss[i].credit_category)" { // 貸方
                    right += objectss[i].credit_amount // 累計額に追加
                }
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objectss[i].balance_left = left - right // 差額を格納
                    objectss[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objectss[i].balance_left = 0
                    objectss[i].balance_right = right - left
                }else {
                    objectss[i].balance_left = 0 // ゼロを入れないと前回値が残る
                    objectss[i].balance_right = 0
                }
            }
        }
        // 損益勘定のみ　繰越利益を含む
        try! realm.write {
            print("損益振替　損益勘定", objectsssss.count, objectsssss!)
            for i in 0..<objectsssss.count { // 勘定内のすべての決算整理仕訳データ
                // 勘定が借方と貸方のどちらか
                if account == "\(objectsssss[i].debit_category)" { // 借方
                    left += objectsssss[i].debit_amount // 累計額に追加
                }else if account == "\(objectsssss[i].credit_category)" { // 貸方
                    right += objectsssss[i].credit_amount // 累計額に追加
                }
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objectsssss[i].balance_left = left - right // 差額を格納
                    objectsssss[i].balance_right = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objectsssss[i].balance_left = 0
                    objectsssss[i].balance_right = right - left
                }else {
                    objectsssss[i].balance_left = 0 // ゼロを入れないと前回値が残る
                    objectsssss[i].balance_right = 0
                }
            }
        }
    }
    
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) ->Int64 {
        if objects.count > 0 {
            let r = indexPath.row
            if objects[r].balance_left > objects[r].balance_right { // 借方と貸方を比較
                balanceAmount = objects[r].balance_left// - objects[r].balance_right
            }else if objects[r].balance_right > objects[r].balance_left {
                balanceAmount = objects[r].balance_right// - objects[r].balance_left
            }else {
                balanceAmount = 0
            }
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) ->String {
        if objects.count > 0 {
            let r = indexPath.row
            if objects[r].balance_left > objects[r].balance_right {
                balanceDebitOrCredit = "借"
            }else if objects[r].balance_left < objects[r].balance_right {
                balanceDebitOrCredit = "貸"
            }else {
                balanceDebitOrCredit = "-"
            }
        }else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    
    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) ->Int64 {
        if objectss.count > 0 {
            let r = indexPath.row
            if objectss[r].balance_left > objectss[r].balance_right { // 借方と貸方を比較
                balanceAmount = objectss[r].balance_left// - objects[r].balance_right
            }else if objectss[r].balance_right > objectss[r].balance_left {
                balanceAmount = objectss[r].balance_right// - objects[r].balance_left
            }else {
                balanceAmount = 0
            }
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) ->String {
        if objectss.count > 0 {
            let r = indexPath.row
            if objectss[r].balance_left > objectss[r].balance_right {
                balanceDebitOrCredit = "借"
            }else if objectss[r].balance_left < objectss[r].balance_right {
                balanceDebitOrCredit = "貸"
            }else {
                balanceDebitOrCredit = "-"
            }
        }else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    
    // 取得　差引残高額　 決算整理仕訳　繰越利益
    func getBalanceAmountAdjustingWithRetainedEarningsCarriedForward(indexPath: IndexPath) ->Int64 {
        if objectssss.count > 0 { // objects_local にへんこうする？
            let r = indexPath.row
            if objectssss[r].balance_left > objectssss[r].balance_right { // 借方と貸方を比較
                balanceAmount = objectssss[r].balance_left// - objects[r].balance_right
            }else if objectssss[r].balance_right > objectssss[r].balance_left {
                balanceAmount = objectssss[r].balance_right// - objects[r].balance_left
            }else {
                balanceAmount = 0
            }
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得 決算整理仕訳 繰越利益
    func getBalanceDebitOrCreditAdjustingWithRetainedEarningsCarriedForward(indexPath: IndexPath) ->String {
        if objectssss.count > 0 { // objects_local にへんこうする？
            let r = indexPath.row
            if objectssss[r].balance_left > objectssss[r].balance_right {
                balanceDebitOrCredit = "借"
            }else if objectssss[r].balance_left < objectssss[r].balance_right {
                balanceDebitOrCredit = "貸"
            }else {
                balanceDebitOrCredit = "-"
            }
        }else {
            balanceDebitOrCredit = "-"
        }
        return balanceDebitOrCredit
    }
    
    // 取得　差引残高額　決算整理仕訳　勘定別 損益勘定のみ　繰越利益を含む
    func getBalanceAmountAdjustingInPLAccount(indexPath: IndexPath) ->Int64 {
        if objectsssss.count > 0 { // objects_local にへんこうする？
            let r = indexPath.row
            if objectsssss[r].balance_left > objectsssss[r].balance_right { // 借方と貸方を比較
                balanceAmount = objectsssss[r].balance_left// - objects[r].balance_right
            }else if objectsssss[r].balance_right > objectsssss[r].balance_left {
                balanceAmount = objectsssss[r].balance_right// - objects[r].balance_left
            }else {
                balanceAmount = 0
            }
        }else {
            balanceAmount = 0
        }
        return balanceAmount
    }
    // 借又貸を取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益を含む
   func getBalanceDebitOrCreditAdjustingInPLAccount(indexPath: IndexPath) ->String {
       if objectsssss.count > 0 { // objects_local にへんこうする？
           let r = indexPath.row
           if objectsssss[r].balance_left > objectsssss[r].balance_right {
               balanceDebitOrCredit = "借"
           }else if objectsssss[r].balance_left < objectsssss[r].balance_right {
               balanceDebitOrCredit = "貸"
           }else {
               balanceDebitOrCredit = "-"
           }
       }else {
           balanceDebitOrCredit = "-"
       }
       return balanceDebitOrCredit
   }
}
