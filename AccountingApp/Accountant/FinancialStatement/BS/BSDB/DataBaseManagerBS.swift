//
//  DataBaseManagerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/14.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 貸借対照表クラス
class DataBaseManagerBS {
    
    // 初期化　中分類、大分類　ごとに計算
    func initializeBS(){
        //0:資産 1:負債 2:純資産
        setTotalBig5(big5: 0)//資産
        setTotalBig5(big5: 1)//負債
        setTotalBig5(big5: 2)//純資産
        
        setTotalRank0(big5: 0, rank0: 0)//流動資産
        setTotalRank0(big5: 0, rank0: 1)//固定資産
        setTotalRank0(big5: 0, rank0: 2)//繰延資産
        setTotalRank0(big5: 1, rank0: 3)//流動負債
        setTotalRank0(big5: 1, rank0: 4)//固定負債
        
        setTotalRank1(big5: 2, rank1: 10)//株主資本
        setTotalRank1(big5: 2, rank1: 11)//その他の包括利益累計額
    }
    // 計算　五大区分
    func setTotalBig5(big5: Int) {
        var TotalAmountOfBig5:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInBig5(big5: big5)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCreditForBig5(big_category: big5, account: objects[i].category) // 5大区分用の貸又借を使用する　2020/11/09
            if totalDebitOrCredit == "-"{
                TotalAmountOfBig5 -= totalAmount
            }else {
                TotalAmountOfBig5 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)

        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        try! realm.write {
            switch big5 {
            case 0: //資産
                objectss!.Asset_total = TotalAmountOfBig5
                break
            case 1: //負債
                objectss!.Liability_total = TotalAmountOfBig5
                break
            case 2: //純資産
                objectss!.Equity_total = TotalAmountOfBig5
                break
            default:
                print("bigCategoryTotalAmount", TotalAmountOfBig5)
                break
            }
        }
    }
    // 取得　設定勘定科目　五大区分
    func getAccountsInBig5(big5: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        switch big5 {
        case 0: // 資産
            objects = objects.filter("Rank0 LIKE '\(0)' OR Rank0 LIKE '\(1)' OR Rank0 LIKE '\(2)'") // 流動資産, 固定資産, 繰延資産
            break
        case 1: // 負債
            objects = objects.filter("Rank0 LIKE '\(3)' OR Rank0 LIKE '\(4)'") // 流動負債, 固定負債
            break
        case 2: // 純資産
            objects = objects.filter("Rank0 LIKE '\(5)'") // 資本, 2020/11/09 不使用　評価・換算差額等　 OR Rank0 LIKE '\(12)'
            break
        default:
            print("")
        }
        return objects
    }
    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: lastYear)
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        var result:Int64 = 0            // 累計額
        switch big5 {
        case 0: //資産
            result = objectss!.Asset_total
            break
        case 1: //負債
            result = objectss!.Liability_total
            break
        case 2: //純資産
            result = objectss!.Equity_total
            break
        case 3: //負債純資産
            result = objectss!.Liability_total+objectss!.Equity_total
            break
        default:
            print(result)
            break
        }
        return setComma(amount: result)
    }
    // 計算　階層0 大区分
    func setTotalRank0(big5: Int, rank0: Int) {
        var TotalAmountOfRank0:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank0(rank0: rank0)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: rank0, mid_category: Int(objects[i].Rank1) ?? 999, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank0 -= totalAmount
            }else {
                TotalAmountOfRank0 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)

        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        try! realm.write {
            switch rank0 {
            case 0: //流動資産
                objectss!.CurrentAssets_total = TotalAmountOfRank0
                break
            case 1: //固定資産
                objectss!.FixedAssets_total = TotalAmountOfRank0
                break
            case 2: //繰延資産
                objectss!.DeferredAssets_total = TotalAmountOfRank0
                break
            case 3: //流動負債
                objectss!.CurrentLiabilities_total = TotalAmountOfRank0
                break
            case 4: //固定負債
                objectss!.FixedLiabilities_total = TotalAmountOfRank0
                break
            default:
                print(TotalAmountOfRank0)
                break
            }
        }
    }
    // 取得　設定勘定科目　大区分
    func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: lastYear)
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        var result:Int64 = 0            // 累計額
        switch rank0 {
        case 0: //流動資産
            result = objectss!.CurrentAssets_total
            break
        case 1: //固定資産
            result = objectss!.FixedAssets_total
            break
        case 2: //繰延資産
            result = objectss!.DeferredAssets_total
            break
        case 3: //流動負債
            result = objectss!.CurrentLiabilities_total
            break
        case 4: //固定負債
            result = objectss!.FixedLiabilities_total
            break
        default:
            print(result)
            break
        }
        return setComma(amount: result)
    }
    // 計算　階層1 中区分
    func setTotalRank1(big5: Int, rank1: Int) {
        var TotalAmountOfRank1:Int64 = 0            // 累計額
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getAccountsInRank1(rank1: rank1)
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{
            let totalAmount = getTotalAmount(account: objects[i].category)
            let totalDebitOrCredit = getTotalDebitOrCredit(big_category: Int(objects[i].Rank0)!, mid_category: rank1, account: objects[i].category)
            if totalDebitOrCredit == "-"{
                TotalAmountOfRank1 -= totalAmount
            }else {
                TotalAmountOfRank1 += totalAmount
            }
        }
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)

        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        try! realm.write {
            switch rank1 {
            case 10: //株主資本
                objectss!.CapitalStock_total = TotalAmountOfRank1
                break
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                objectss!.OtherCapitalSurpluses_total = TotalAmountOfRank1
                break
//            case 12: //新株予約権
//            case 19: //非支配株主持分
            default:
                print()
                break
            }
        }
    }
    // 取得　設定勘定科目　中区分
    func getAccountsInRank1(rank1: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank1 LIKE '\(rank1)'")
        return objects
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: lastYear)
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet
        var result:Int64 = 0            // 累計額
        switch rank1 {
            case 10: //株主資本
                result = objectss!.CapitalStock_total
                break
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                result = objectss!.OtherCapitalSurpluses_total
                break
//            case 12: //新株予約権
//            case 19: //非支配株主持分
        default:
            print(result)
            break
        }
        return setComma(amount: result)
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか　決算整理後の値を利用する
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    result = objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting
                }else {
                    result = objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting
                }
            }
        }
        return result
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, mid_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var DebitOrCredit:String = "" // 借又貸
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "借"
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "貸"
                }else {
                    DebitOrCredit = "-"
                }
            }
        }
        var PositiveOrNegative:String = "" // 借又貸
        switch big_category {
        case 0,1,2,7,8,11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        case 9,10: // 営業外損益 特別損益
            if mid_category == 15 || mid_category == 17 {
                switch DebitOrCredit {
                case "借":
                    PositiveOrNegative = "-"
                    break
                default:
                    PositiveOrNegative = ""
                    break
                }
            }else if mid_category == 16 || mid_category == 18 {
                switch DebitOrCredit {
                case "貸":
                    PositiveOrNegative = "-"
                    break
                default:
                    PositiveOrNegative = ""
                    break
                }
            }
            break
        default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
            switch DebitOrCredit {
            case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        }
        return PositiveOrNegative
    }
    // 借又貸を取得 5大区分用
    func getTotalDebitOrCreditForBig5(big_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var DebitOrCredit:String = "" // 借又貸
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか
                if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting > objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "借"
                }else if objectss!.dataBaseAccounts[i].debit_balance_AfterAdjusting < objectss!.dataBaseAccounts[i].credit_balance_AfterAdjusting {
                    DebitOrCredit = "貸"
                }else {
                    DebitOrCredit = "-"
                }
            }
        }
        var PositiveOrNegative:String = "" // 借又貸
        switch big_category {
        case 0,3: // 資産　費用
            switch DebitOrCredit {
            case "貸":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        default: // 1,2,4（負債、純資産、収益）
            switch DebitOrCredit {
            case "借":
                PositiveOrNegative = "-"
                break
            default:
                PositiveOrNegative = ""
                break
            }
        }
        return PositiveOrNegative
    }
    // コンマを追加
    func setComma(amount: Int64) -> String {
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        // 三角形はマイナスの意味
        if amount < 0 { //0の場合は、空白を表示する
            let amauntFix = amount * -1
            return "△ \(addComma(string: amauntFix.description))"
        }else {
            return addComma(string: amount.description)
        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String{
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        if(string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    //カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String{
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
}
