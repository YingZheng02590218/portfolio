//
//  DataBaseManagerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益計算書クラス
class DataBaseManagerPL {
    
    // 初期化　中区分、大区分　ごとに計算
    func initializeBenefits(){
        // データベースに書き込み　//4:収益 3:費用
        setTotalRank0(big5: 4,rank0:  6) //営業収益9     売上
        setTotalRank0(big5: 3,rank0:  7) //営業費用5     売上原価
        setTotalRank0(big5: 3,rank0:  8) //営業費用5     販売費及び一般管理費
        setTotalRank0(big5: 3,rank0: 11) //税等8        法人税等 税金

        setTotalRank1(big5: 4, rank1: 15) //営業外収益10 営業外損益    営業外収益
        setTotalRank1(big5: 3, rank1: 16) //営業外費用6  営業外損益    営業外費用
        setTotalRank1(big5: 4, rank1: 17) //特別利益11   特別損益    特別利益
        setTotalRank1(big5: 3, rank1: 18) //特別損失7    特別損益    特別損失
        
        // 利益を計算する関数を呼び出す todo
        setBenefitTotal()
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
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        
        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        try! realm.write {
            switch rank0 {
            case 6: //営業収益9     売上
                objectss!.NetSales = TotalAmountOfRank0
                break
            case 7: //営業費用5     売上原価
                objectss!.CostOfGoodsSold = TotalAmountOfRank0
                break
            case 8: //営業費用5     販売費及び一般管理費
                objectss!.SellingGeneralAndAdministrativeExpenses = TotalAmountOfRank0
                break
            case 11: //税等8 法人税等 税金
                objectss!.IncomeTaxes = TotalAmountOfRank0
                break
            default:
                print()
            }
        }
    }
    // 取得　階層0 大区分
    func getTotalRank0(big5: Int, rank0: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0
        switch rank0 {
        case 6: //営業収益9     売上
            result = objectss!.NetSales
            break
        case 7: //営業費用5     売上原価
            result = objectss!.CostOfGoodsSold
            break
        case 8: //営業費用5     販売費及び一般管理費
            result = objectss!.SellingGeneralAndAdministrativeExpenses
            break
        case 11: //税等8 法人税等 税金
            result = objectss!.IncomeTaxes
            break
        default:
            print(result)
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
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()

        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        try! realm.write {
            switch rank1 {
            case 15: //営業外収益10  営業外損益    営業外収益
                objectss!.NonOperatingIncome = TotalAmountOfRank1
                break
            case 16: //営業外費用6  営業外損益    営業外費用
                objectss!.NonOperatingExpenses = TotalAmountOfRank1
                break
            case 17: //特別利益11   特別損益    特別利益
                objectss!.ExtraordinaryIncome = TotalAmountOfRank1
                break
            case 18: //特別損失7    特別損益    特別損失
                objectss!.ExtraordinaryLosses = TotalAmountOfRank1
                break
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
    // 取得　階層1 中区分
    func getTotalRank1(big5: Int, rank1: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0            // 累計額
        switch rank1 {
        case 15: //営業外収益10  営業外損益    営業外収益
            result = objectss!.NonOperatingIncome
            break
        case 16: //営業外費用6  営業外損益    営業外費用
            result = objectss!.NonOperatingExpenses
            break
        case 17: //特別利益11   特別損益    特別利益
            result = objectss!.ExtraordinaryIncome
            break
        case 18: //特別損失7    特別損益    特別損失
            result = objectss!.ExtraordinaryLosses
            break
        default:
            print(result)
            break
        }
        return setComma(amount: result)
    }
    // 利益　計算
    func setBenefitTotal() {
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()

        // 利益5種類　売上総利益、営業利益、経常利益、税金等調整前当期純利益、当期純利益
        for i in 0..<5 {
            let realm = try! Realm()
            let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
            try! realm.write {
                switch i {
                case 0: //売上総利益
                    objectss!.GrossProfitOrLoss = objectss!.NetSales - objectss!.CostOfGoodsSold
                    break
                case 1: //営業利益
                    objectss!.OtherCapitalSurpluses_total = objectss!.GrossProfitOrLoss - objectss!.SellingGeneralAndAdministrativeExpenses
                    break
                case 2: //経常利益
                    objectss!.OrdinaryIncomeOrLoss = objectss!.OtherCapitalSurpluses_total + objectss!.NonOperatingIncome - objectss!.NonOperatingExpenses
                    break
                case 3: //税引前当期純利益（損失）
                    objectss!.IncomeOrLossBeforeIncomeTaxes = objectss!.OrdinaryIncomeOrLoss + objectss!.ExtraordinaryIncome - objectss!.ExtraordinaryLosses
                    break
                case 4: //当期純利益（損失）
                    objectss!.NetIncomeOrLoss = objectss!.IncomeOrLossBeforeIncomeTaxes - objectss!.IncomeTaxes
                    break
                default:
                    print()
                    break
                }
            }
        }
    }
    // 利益　取得
    func getBenefitTotal(benefit: Int) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.profitAndLossStatement
        var result:Int64 = 0            // 累計額
        switch benefit {
        case 0: //売上総利益
            result = objectss!.GrossProfitOrLoss
            break
        case 1: //営業利益
            result = objectss!.OtherCapitalSurpluses_total
            break
        case 2: //経常利益
            result = objectss!.OrdinaryIncomeOrLoss
            break
        case 3: //税引前当期純利益（損失）
            result = objectss!.IncomeOrLossBeforeIncomeTaxes
            break
        case 4: //当期純利益（損失）
            result = objectss!.NetIncomeOrLoss
            break
        default:
            print(result)
            break
        }
        return setComma(amount: result)
    }
    // 合計残高　勘定別の合計額　借方と貸方でより大きい方の合計を取得
    func getTotalAmount(account: String) ->Int64 {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
//        let realm = try! Realm()
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 決算整理後の値を利用する
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
    // 取得　設定勘定科目　大区分
    func getAccountsInRank0(rank0: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.sorted(byKeyPath: "number", ascending: true)
        objects = objects.filter("Rank0 LIKE '\(rank0)'")
        return objects
    }
    // 借又貸を取得
    func getTotalDebitOrCredit(big_category: Int, mid_category: Int, account: String) ->String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
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
