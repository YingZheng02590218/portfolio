//
//  DataBaseManagerTB.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 合計残高試算表クラス
class DataBaseManagerTB {
    
    // 計算　合計残高試算表クラス　合計（借方、貸方）、残高（借方、貸方）の集計
    func calculateAmountOfAllAccount(){
        // 総勘定元帳　取得
        let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
        let objectsOfGL = dataBaseManagerGeneralLedger.getGeneralLedger()
        // 財務諸表　取得
        let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
        let object = dataBaseManagerFinancialStatements.getFinancialStatements()

        let realm = try! Realm()
        try! realm.write {
            for r in 0..<4 { //注意：3になっていた。誤り
                var l: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
                for i in 0..<objectsOfGL.dataBaseAccounts.count {
                    l += getTotalAmount(account: objectsOfGL.dataBaseAccounts[i].accountName, leftOrRight: r) // 累計額に追加
                }
                switch r {
                case 0: // 合計　借方
                    object.compoundTrialBalance?.debit_total_total = l// + k
                    break
                case 1: // 合計　貸方
                    object.compoundTrialBalance?.credit_total_total = l// + k
                    break
                case 2: // 残高　借方
                    object.compoundTrialBalance?.debit_balance_total = l// + k
                    break
                case 3: // 残高　貸方
                    object.compoundTrialBalance?.credit_balance_total = l// + k
                    break
                default:
                    print("default calculateAmountOfAllAccount")
                    break
                }
            }
        }
    }
    // 設定　仕訳と決算整理後　勘定クラス　全ての勘定
    func setAllAccountTotal(){
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objects = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountAdjustingSwitch(AdjustingAndClosingEntries: false, switching: true)
        for i in 0..<objects.count{
            // クリア
            clearAccountTotal(account: objects[i].category)
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: objects[i].category)
            // 勘定別に決算整理仕訳データを集計
            calculateAccountTotalAdjusting(account: objects[i].category)
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: objects[i].category)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        // 資本振替仕訳後に、繰越利益勘定の決算整理前と決算整理仕訳、決算整理後の合計額と残高額の集計は必要ないのか？
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
    }
    // 設定　仕訳と決算整理後　勘定クラス　個別の勘定別　仕訳データを追加後に、呼び出される
    func setAccountTotal(account_left: String, account_right: String) {
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        if account_left != "損益勘定" {
            // 勘定別に仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotal(account: account_left ) // 借方
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: account_left )
        }
        if account_right != "損益勘定" {
            calculateAccountTotal(account: account_right) // 貸方
            calculateAccountTotalAfterAdjusting(account: account_right)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
        // 設定表示科目　初期化 毎回行うと時間がかかる
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if account_left != "損益勘定" {
            dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: account_left)) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
        }
        if account_right != "損益勘定" {
            dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: account_right))
        }
        dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: "繰越利益"))
        // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
    }
    // 設定　決算整理仕訳と決算整理後　勘定クラス　個別の勘定別　決算整理仕訳データを追加後に、呼び出される
    func setAccountTotalAdjusting(account_left: String,account_right: String){
        // 注意：損益振替仕訳を削除すると、エラーが発生するので、account_leftもしくは、account_rightが損益勘定の場合は下記を実行しない。
        if account_left != "損益勘定" {
            // 勘定別に決算整理仕訳データを集計　勘定ごとに保持している合計と残高を再計算する処理
            calculateAccountTotalAdjusting(account: account_left) // 借方
            // 勘定別の決算整理後の集計
            calculateAccountTotalAfterAdjusting(account: account_left)
        }
        if account_right != "損益勘定" {
            calculateAccountTotalAdjusting(account: account_right) // 貸方
            calculateAccountTotalAfterAdjusting(account: account_right)
        }
        // 損益振替仕訳　資本振替仕訳
        clearAccountTotal(account: "損益勘定") // クリア
        calculateAccountTotal(account: "損益勘定") // 集計　決算整理前
        calculateAccountTotalAdjusting(account: "損益勘定") // 集計　決算整理仕訳
        calculateAccountTotalAfterAdjusting(account: "損益勘定") // 集計　決算整理後
        clearAccountTotal(account: "繰越利益")
        calculateAccountTotal(account: "繰越利益")
        calculateAccountTotalAdjusting(account: "繰越利益")
        calculateAccountTotalAfterAdjusting(account: "繰越利益")
        // 設定表示科目　初期化 毎回行うと時間がかかる
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if account_left != "損益勘定" {
            dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: account_left)) // 勘定科目の名称から、紐づけられた設定表示科目の連番を取得する
        }
        if account_right != "損益勘定" {
            
            dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: account_right))
        }
        dataBaseManagerTaxonomy.setTotalOfTaxonomy(numberOfSettingsTaxonomy: databaseManagerSettingsTaxonomyAccount.getNumberOfTaxonomy(category: "繰越利益"))
        // 表示科目　貸借対照表の大区分と中区分の合計額と、表示科目の集計額を集計 は、BS画面のwillAppear()で行う
    }
    //　クリア　勘定クラス　決算整理前、決算整理仕訳、決算整理後（合計、残高）
    func clearAccountTotal(account: String) {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        try! realm.write {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        objectss?.dataBaseAccounts[i].debit_total = 0
                        objectss?.dataBaseAccounts[i].credit_total = 0
                        objectss?.dataBaseAccounts[i].debit_balance = 0
                        objectss?.dataBaseAccounts[i].credit_balance = 0
                        
                        objectss?.dataBaseAccounts[i].debit_total_Adjusting = 0
                        objectss?.dataBaseAccounts[i].credit_total_Adjusting = 0
                        objectss?.dataBaseAccounts[i].debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                        objectss?.dataBaseAccounts[i].credit_balance_Adjusting = 0
                        
                        objectss?.dataBaseAccounts[i].debit_total_AfterAdjusting = 0
                        objectss?.dataBaseAccounts[i].credit_total_AfterAdjusting = 0
                        objectss?.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0
                        objectss?.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0
                    }
                }
            }else { // 損益勘定の場合
                objectss?.dataBasePLAccount?.debit_total = 0
                objectss?.dataBasePLAccount?.credit_total = 0
                objectss?.dataBasePLAccount?.debit_balance = 0
                objectss?.dataBasePLAccount?.credit_balance = 0
                
                objectss?.dataBasePLAccount?.debit_total_Adjusting = 0
                objectss?.dataBasePLAccount?.credit_total_Adjusting = 0
                objectss?.dataBasePLAccount?.debit_balance_Adjusting = 0
                objectss?.dataBasePLAccount?.credit_balance_Adjusting = 0
                
                objectss?.dataBasePLAccount?.debit_total_AfterAdjusting = 0
                objectss?.dataBasePLAccount?.credit_total_AfterAdjusting = 0
                objectss?.dataBasePLAccount?.debit_balance_AfterAdjusting = 0
                objectss?.dataBasePLAccount?.credit_balance_AfterAdjusting = 0
            }
        }
    }
    //　計算 決算整理前　勘定クラス　勘定別に仕訳データを集計
    func calculateAccountTotal(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let objects = dataBaseManagerAccount.getAllJournalEntryInAccount(account: account)
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            }else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        try! realm.write {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        // 借方と貸方で金額が大きい方はどちらか
                        if left > right {
                            objectss?.dataBaseAccounts[i].debit_total = left
                            objectss?.dataBaseAccounts[i].credit_total = right
                            objectss?.dataBaseAccounts[i].debit_balance = left - right // 差額を格納
                            objectss?.dataBaseAccounts[i].credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        }else if left < right {
                            objectss?.dataBaseAccounts[i].debit_total = left
                            objectss?.dataBaseAccounts[i].credit_total = right
                            objectss?.dataBaseAccounts[i].debit_balance = 0
                            objectss?.dataBaseAccounts[i].credit_balance = right - left
                        }else {
                            objectss?.dataBaseAccounts[i].debit_total = left
                            objectss?.dataBaseAccounts[i].credit_total = right
                            objectss?.dataBaseAccounts[i].debit_balance = 0 // ゼロを入れないと前回値が残る
                            objectss?.dataBaseAccounts[i].credit_balance = 0
                        }
                    }
                }
            }else { // 損益勘定の場合
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objectss?.dataBasePLAccount?.debit_total = left
                    objectss?.dataBasePLAccount?.credit_total = right
                    objectss?.dataBasePLAccount?.debit_balance = left - right // 差額を格納
                    objectss?.dataBasePLAccount?.credit_balance = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objectss?.dataBasePLAccount?.debit_total = left
                    objectss?.dataBasePLAccount?.credit_total = right
                    objectss?.dataBasePLAccount?.debit_balance = 0
                    objectss?.dataBasePLAccount?.credit_balance = right - left
                }else {
                    objectss?.dataBasePLAccount?.debit_total = left
                    objectss?.dataBasePLAccount?.credit_total = right
                    objectss?.dataBasePLAccount?.debit_balance = 0 // ゼロを入れないと前回値が残る
                    objectss?.dataBasePLAccount?.credit_balance = 0
                }
            }
        }
    }
    //　計算 決算整理仕訳　勘定クラス　勘定別に決算整理仕訳データを集計
    func calculateAccountTotalAdjusting(account: String) {
        var left: Int64 = 0 // 合計 累積　勘定内の仕訳データを全て計算するまで、覚えておく
        var right: Int64 = 0
        let dataBaseManagerAccount = DataBaseManagerAccount()
        var objects:Results<DataBaseAdjustingEntry>
        if account != "損益勘定" && account != "繰越利益" {
            objects = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: account)
        }else if account == "繰越利益" {
            objects = dataBaseManagerAccount.getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: account)
        }else {
            objects = dataBaseManagerAccount.getAllAdjustingEntryInPLAccount(account: account)
        }
        for i in 0..<objects.count { // 勘定内のすべての仕訳データ
            // 勘定が借方と貸方のどちらか
            if account == "\(objects[i].debit_category)" { // 借方
                left += objects[i].debit_amount // 累計額に追加
            }else if account == "\(objects[i].credit_category)" { // 貸方
                right += objects[i].credit_amount // 累計額に追加
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        try! realm.write {
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        // 借方と貸方で金額が大きい方はどちらか
                        if left > right {
                            objectss?.dataBaseAccounts[i].debit_total_Adjusting = left
                            objectss?.dataBaseAccounts[i].credit_total_Adjusting = right
                            objectss?.dataBaseAccounts[i].debit_balance_Adjusting = left - right // 差額を格納
                            objectss?.dataBaseAccounts[i].credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                        }else if left < right {
                            objectss?.dataBaseAccounts[i].debit_total_Adjusting = left
                            objectss?.dataBaseAccounts[i].credit_total_Adjusting = right
                            objectss?.dataBaseAccounts[i].debit_balance_Adjusting = 0
                            objectss?.dataBaseAccounts[i].credit_balance_Adjusting = right - left
                        }else {
                            objectss?.dataBaseAccounts[i].debit_total_Adjusting = left
                            objectss?.dataBaseAccounts[i].credit_total_Adjusting = right
                            objectss?.dataBaseAccounts[i].debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                            objectss?.dataBaseAccounts[i].credit_balance_Adjusting = 0
                        }
                    }
                }
            }else { // 損益勘定の場合
                // 借方と貸方で金額が大きい方はどちらか
                if left > right {
                    objectss?.dataBasePLAccount?.debit_total_Adjusting = left
                    objectss?.dataBasePLAccount?.credit_total_Adjusting = right
                    objectss?.dataBasePLAccount?.debit_balance_Adjusting = left - right // 差額を格納
                    objectss?.dataBasePLAccount?.credit_balance_Adjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                }else if left < right {
                    objectss?.dataBasePLAccount?.debit_total_Adjusting = left
                    objectss?.dataBasePLAccount?.credit_total_Adjusting = right
                    objectss?.dataBasePLAccount?.debit_balance_Adjusting = 0
                    objectss?.dataBasePLAccount?.credit_balance_Adjusting = right - left
                }else {
                    objectss?.dataBasePLAccount?.debit_total_Adjusting = left
                    objectss?.dataBasePLAccount?.credit_total_Adjusting = right
                    objectss?.dataBasePLAccount?.debit_balance_Adjusting = 0 // ゼロを入れないと前回値が残る
                    objectss?.dataBasePLAccount?.credit_balance_Adjusting = 0
                }
            }
        }
    }
    // 計算　決算整理後　勘定クラス　勘定別の決算整理後の集計 決算整理前+決算整理事項=決算整理後
    private func calculateAccountTotalAfterAdjusting(account: String) { // 損益勘定 用も作る
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        // 決算振替仕訳　損益勘定振替
        let dataBaseManagerPLAccount = DataBaseManagerPLAccount()
        
        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        try! realm.write {
            if account != "損益勘定" {//} && account != "繰越利益" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
                        objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting = objectss!.dataBaseAccounts[i].debit_total + objectss!.dataBaseAccounts[i].debit_total_Adjusting
                        objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting = objectss!.dataBaseAccounts[i].credit_total + objectss!.dataBaseAccounts[i].credit_total_Adjusting
                        // 残高額　借方と貸方で金額が大きい方はどちらか
                        if objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting {
                            objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting =
                                objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting -
                                objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting // 差額を格納
                            objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            // 決算振替仕訳　損益勘定振替
                            if account != "繰越利益" { // 繰越利益の日付が手動で変更される可能性がある
                                dataBaseManagerPLAccount.addTransferEntry(debit_category: account, amount: objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting, credit_category: "損益勘定")
                            }
                        }else if objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting {
                            objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting =
                                objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting -
                                objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting // 差額を格納
                            objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                            // 決算振替仕訳　損益勘定振替
                            if account != "繰越利益" { // 繰越利益の日付が手動で変更される可能性がある
                                dataBaseManagerPLAccount.addTransferEntry(debit_category: "損益勘定", amount: objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting, credit_category: account)
                            }
                        }else {
                            objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                            objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                            // 決算振替仕訳　損益勘定振替 差額がない勘定は損益振替しなくてもよいのか？　2020/10/05
                            dataBaseManagerPLAccount.addTransferEntry(debit_category: "損益勘定", amount: 0, credit_category: account)
                        }
                    }
                }
            }else { // 損益勘定の場合
                // 合計額 通常仕訳＋決算整理仕訳＝決算整理後
                objectss!.dataBasePLAccount!.debit_total_AfterAdjusting = objectss!.dataBasePLAccount!.debit_total + objectss!.dataBasePLAccount!.debit_total_Adjusting
                objectss!.dataBasePLAccount!.credit_total_AfterAdjusting = objectss!.dataBasePLAccount!.credit_total + objectss!.dataBasePLAccount!.credit_total_Adjusting
                // 残高額　借方と貸方で金額が大きい方はどちらか
                if objectss!.dataBasePLAccount!.debit_total_AfterAdjusting > objectss!.dataBasePLAccount!.credit_total_AfterAdjusting {
                    objectss!.dataBasePLAccount!.debit_balance_AfterAdjusting =
                        objectss!.dataBasePLAccount!.debit_total_AfterAdjusting -
                        objectss!.dataBasePLAccount!.credit_total_AfterAdjusting // 差額を格納
                    objectss!.dataBasePLAccount!.credit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    // 決算振替仕訳　損益勘定の締切り
                    dataBaseManagerPLAccount.addTransferEntryToNetWorth(debit_category: "損益勘定", amount: objectss!.dataBasePLAccount!.debit_balance_AfterAdjusting, credit_category: "繰越利益")
                }else if objectss!.dataBasePLAccount!.debit_total_AfterAdjusting < objectss!.dataBasePLAccount!.credit_total_AfterAdjusting {
                    objectss!.dataBasePLAccount!.credit_balance_AfterAdjusting =
                        objectss!.dataBasePLAccount!.credit_total_AfterAdjusting -
                        objectss!.dataBasePLAccount!.debit_total_AfterAdjusting // 差額を格納
                    objectss!.dataBasePLAccount!.debit_balance_AfterAdjusting = 0 // 相手方勘定を0にしないと、getBalanceAmountの計算がおかしくなる
                    // 決算振替仕訳　損益勘定の締切り
                    dataBaseManagerPLAccount.addTransferEntryToNetWorth(debit_category: "繰越利益", amount: objectss!.dataBasePLAccount!.credit_balance_AfterAdjusting, credit_category: "損益勘定")
                }else {
                    objectss!.dataBasePLAccount!.debit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                    objectss!.dataBasePLAccount!.credit_balance_AfterAdjusting = 0 // ゼロを入れないと前回値が残る
                    // 決算振替仕訳　損益勘定の締切り 記述漏れ　2020/11/05
                    dataBaseManagerPLAccount.addTransferEntryToNetWorth(debit_category: "繰越利益", amount: 0, credit_category: "損益勘定")
                }
            }
        }
        // 差引残高　計算 注意：エラーが発生するため、このメソッドの try! realm.write{} より外で下記の処理を呼び出す。
        let dataBaseManagerGeneralLedgerAccountBalance = DataBaseManagerGeneralLedgerAccountBalance()
        dataBaseManagerGeneralLedgerAccountBalance.calculateBalance(account: account)
    }
    // 取得　決算整理前　勘定クラス　合計、残高　勘定別の決算整理前の合計残高
    func getTotalAmount(account: String, leftOrRight: Int) -> Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        if account != "損益勘定" {
            // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
            for i in 0..<objectss!.dataBaseAccounts.count {
                if objectss!.dataBaseAccounts[i].accountName == account {
                    switch leftOrRight {
                    case 0: // 合計　借方
                        result = objectss!.dataBaseAccounts[i].debit_total
                        break
                    case 1: // 合計　貸方
                        result = objectss!.dataBaseAccounts[i].credit_total
                        break
                    case 2: // 残高　借方
                        result = objectss!.dataBaseAccounts[i].debit_balance
                        break
                    case 3: // 残高　貸方
                        result = objectss!.dataBaseAccounts[i].credit_balance
                        break
                    default:
                        print("getTotalAmount")
                        break
                    }
                }
            }
        }else {
            switch leftOrRight {
            case 0: // 合計　借方
                result = objectss!.dataBasePLAccount!.debit_total
                break
            case 1: // 合計　貸方
                result = objectss!.dataBasePLAccount!.credit_total
                break
            case 2: // 残高　借方
                result = objectss!.dataBasePLAccount!.debit_balance
                break
            case 3: // 残高　貸方
                result = objectss!.dataBasePLAccount!.credit_balance
                break
            default:
                print("getTotalAmount 損益勘定")
                break
            }
        }
        return result
    }
    // 取得　決算整理仕訳　勘定クラス　合計、残高　勘定別の決算整理仕訳の合計額
    func getTotalAmountAdjusting(account: String, leftOrRight: Int) -> Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        if account == "繰越利益" { // 精算表作成後に、資本振替仕訳を行うので、繰越利益の決算整理仕訳は計算に含まない。
            result = 0
        }else{
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = objectss!.dataBaseAccounts[i].debit_total_Adjusting
                            break
                        case 1: // 合計　貸方
                            result = objectss!.dataBaseAccounts[i].credit_total_Adjusting
                            break
                        case 2: // 残高　借方
                            result = objectss!.dataBaseAccounts[i].debit_balance_Adjusting
                            break
                        case 3: // 残高　貸方
                            result = objectss!.dataBaseAccounts[i].credit_balance_Adjusting
                            break
                        default:
                            print("getTotalAmountAdjusting")
                            break
                        }
                    }
                }
            }else {
                switch leftOrRight {
                case 0: // 合計　借方
                    result = objectss!.dataBasePLAccount!.debit_total_Adjusting
                    break
                case 1: // 合計　貸方
                    result = objectss!.dataBasePLAccount!.credit_total_Adjusting
                    break
                case 2: // 残高　借方
                    result = objectss!.dataBasePLAccount!.debit_balance_Adjusting
                    break
                case 3: // 残高　貸方
                    result = objectss!.dataBasePLAccount!.credit_balance_Adjusting
                    break
                default:
                    print("getTotalAmountAdjusting 損益勘定")
                    break
                }
            }
        }
        return result
    }
    // 取得　決算整理後　勘定クラス　合計、残高　勘定別の決算整理後の合計額
    func getTotalAmountAfterAdjusting(account: String, leftOrRight: Int) -> Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        if account == "繰越利益" { // 精算表作成後に、資本振替仕訳を行うので、繰越利益の決算整理仕訳は計算に含まない。
            result = 0
        }else{
            if account != "損益勘定" {
                // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                for i in 0..<objectss!.dataBaseAccounts.count {
                    if objectss!.dataBaseAccounts[i].accountName == account {
                        switch leftOrRight {
                        case 0: // 合計　借方
                            result = objectss!.dataBaseAccounts[i].debit_total_AfterAdjusting
                            break
                        case 1: // 合計　貸方
                            result = objectss!.dataBaseAccounts[i].credit_total_AfterAdjusting
                            break
                        case 2: // 残高　借方
                            result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                            break
                        case 3: // 残高　貸方
                            result = objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting
                            break
                        default:
                            print("getTotalAmountAfterAdjusting")
                            break
                        }
                    }
                }
            }else {
                switch leftOrRight {
                case 0: // 合計　借方
                    result = objectss!.dataBasePLAccount!.debit_total_AfterAdjusting
                    break
                case 1: // 合計　貸方
                    result = objectss!.dataBasePLAccount!.credit_total_AfterAdjusting
                    break
                case 2: // 残高　借方
                    result = objectss!.dataBasePLAccount!.debit_balance_AfterAdjusting
                    break
                case 3: // 残高　貸方
                    result = objectss!.dataBasePLAccount!.credit_balance_AfterAdjusting
                    break
                default:
                    print("getTotalAmountAfterAdjusting 損益勘定")
                    break
                }
            }
        }
        return result
    }
}
