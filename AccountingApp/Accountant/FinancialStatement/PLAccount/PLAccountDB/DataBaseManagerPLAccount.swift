//
//  DataBaseManagerPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益勘定クラス
class DataBaseManagerPLAccount  {

    // チェック 決算整理仕訳　損益勘定内の勘定が存在するかを確認
    func checkAdjustingEntryInPLAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
                .filter("fiscalYear == \(fiscalYear)")
                .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
        return objects//.count >= 1
    }
    // 追加　決算振替仕訳　損益振替
    // 引数：日付、借方勘定、勘定残高額借方、貸方勘定、勘定残高貸方、小書き
    func addTransferEntry(debit_category: String, amount: Int64,credit_category: String) {
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debit_category == "損益勘定" {
            account = credit_category
        }else if credit_category == "損益勘定" {
            account = debit_category
        }
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if databaseManagerSettingsTaxonomyAccount.checkSettingsTaxonomyAccountRank0(account: account) {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          //仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let dataBaseManagerPeriod = DataBaseManagerPeriod()
            let object = dataBaseManagerPeriod.getSettingsPeriod()
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 現在時刻を取得
            let now :Date = Date() // UTC時間なので　9時間ずれる
            let f     = DateFormatter() //年
            let fff   = DateFormatter() //月日
            f.dateFormat    = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
            f.timeZone = .current
            fff.dateFormat  = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
            fff.timeZone = .current
            dataBaseJournalEntry.date = String(fiscalYear!+1) + "/03/31"
            dataBaseJournalEntry.debit_category = credit_category    //借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        //借方金額
            dataBaseJournalEntry.credit_category = debit_category  //貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      //貸方金額
            dataBaseJournalEntry.smallWritting = "損益振替仕訳"      //小書き
            
            // 損益振替仕訳　が存在する場合は　更新
            let objects = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
            if objects.count >= 1 {
                if amount != 0 {
                    number = updateAdjustingJournalEntry(
                        primaryKey: objects[0].number,
                        date: dataBaseJournalEntry.date,
                        debit_category: dataBaseJournalEntry.debit_category,
                        debit_amount: Int64(dataBaseJournalEntry.debit_amount), //カンマを削除してからデータベースに書き込む
                        credit_category: dataBaseJournalEntry.credit_category,
                        credit_amount: Int64(dataBaseJournalEntry.credit_amount),//カンマを削除してからデータベースに書き込む
                        smallWritting: dataBaseJournalEntry.smallWritting
                    )
                }else{ // 貸借が0の場合　削除する
                    let isInvalidated = deleteAdjustingJournalEntry(number: objects[0].number)
                    print(isInvalidated)
                }
            }else {
                if amount != 0 {
                    number = dataBaseJournalEntry.save() //仕訳番号　自動採番
                    // 仕訳帳に仕訳データを追加
                    object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    //勘定へ転記 // オブジェクトを作成
                    if credit_category == "損益勘定" {
                        let objectss = object.dataBaseGeneralLedger
                        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                        for i in 0..<objectss!.dataBaseAccounts.count {
                            if objectss!.dataBaseAccounts[i].accountName == credit_category {
                                // 勘定に借方の仕訳データを追加
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                        }
                        // 勘定に貸方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }else if debit_category == "損益勘定" {
                        // 勘定に借方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        // 勘定に貸方の仕訳データを追加
                        let objectss = object.dataBaseGeneralLedger
                        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                        for i in 0..<objectss!.dataBaseAccounts.count {
                            if objectss!.dataBaseAccounts[i].accountName == debit_category {
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                        }
                    }
                }
            }
        }
    }
    // 追加　決算振替仕訳　資本振替
    // 引数：日付、借方勘定、金額、貸方勘定
    func addTransferEntryToNetWorth(debit_category: String,amount: Int64,credit_category: String) {
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debit_category == "損益勘定" {
            account = credit_category
        }else if credit_category == "損益勘定" {
            account = debit_category
        }
        if account == "繰越利益" {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          //仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let dataBaseManagerPeriod = DataBaseManagerPeriod()
            let object = dataBaseManagerPeriod.getSettingsPeriod()
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 現在時刻を取得
            let f     = DateFormatter() //年
            f.dateFormat    = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
            f.timeZone = .current
            dataBaseJournalEntry.date = String(fiscalYear!+1) + "/03/31"
            dataBaseJournalEntry.debit_category = credit_category    //借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        //借方金額
            dataBaseJournalEntry.credit_category = debit_category  //貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      //貸方金額
            dataBaseJournalEntry.smallWritting = "資本振替仕訳"
            // 資本振替仕訳　が存在する場合は　更新
            let objects = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
            if objects.count >= 1 {
                number = updateAdjustingJournalEntry(
                    primaryKey: objects[0].number,
                    date: dataBaseJournalEntry.date,
                    debit_category: dataBaseJournalEntry.debit_category,
                    debit_amount: Int64(dataBaseJournalEntry.debit_amount), //カンマを削除してからデータベースに書き込む
                    credit_category: dataBaseJournalEntry.credit_category,
                    credit_amount: Int64(dataBaseJournalEntry.credit_amount),//カンマを削除してからデータベースに書き込む
                    smallWritting: dataBaseJournalEntry.smallWritting
                )
            }else {
                if amount != 0 {
                    number = dataBaseJournalEntry.save() //仕訳番号　自動採番
                    // 仕訳帳に仕訳データを追加
                    object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    //勘定へ転記 // オブジェクトを作成
                    if credit_category == "損益勘定" {
                        // 勘定に借方の仕訳データを追加
                        let objectss = object.dataBaseGeneralLedger
                        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                        for i in 0..<objectss!.dataBaseAccounts.count {
                            if objectss!.dataBaseAccounts[i].accountName == credit_category {
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                        }
                        // 勘定に貸方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }else if debit_category == "損益勘定" {
                        // 勘定に借方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                        // 勘定に貸方の仕訳データを追加
                        let objectss = object.dataBaseGeneralLedger
                        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                        for i in 0..<objectss!.dataBaseAccounts.count {
                            if objectss!.dataBaseAccounts[i].accountName == debit_category {
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                        }
                    }
                }
            }
        }
    }
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 編集前の借方勘定と貸方勘定をメモする
        // (2)書き込みトランザクション内でデータを更新する
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
        return primaryKey
    }
    // 削除　決算整理仕訳 損益振替仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: number)!
            realm.delete(object)
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
