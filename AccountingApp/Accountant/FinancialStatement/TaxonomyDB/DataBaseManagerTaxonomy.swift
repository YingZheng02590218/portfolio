//
//  DataBaseManagerTaxonomy.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 表示科目クラス
class DataBaseManagerTaxonomy {

    // 初期化
    func initializeTaxonomy(){
        // 設定表示科目
        let dataBaseManager = DataBaseManagerSettingsTaxonomy()
        let objects = dataBaseManager.getAllSettingsTaxonomySwitichON()
        // 設定表示科目に存在する表示科目の数だけ、計算とDBへの書き込みを行う
        for i in 0..<objects.count {
            setTotalOfTaxonomy(numberOfSettingsTaxonomy: objects[i].number)
        }
    }
    // 取得　設定勘定科目　設定表示科目の連番から設定表示科目別の設定勘定科目
    func getAccountsInTaxonomy(numberOfTaxonomy: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        let realm = try! Realm()
        // 設定勘定科目クラス
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        objects = objects.filter("numberOfTaxonomy LIKE '\(numberOfTaxonomy)'")
        if objects.count == 0 {
//            print("ゼロ　getAccountsInTaxonomy", numberOfTaxonomy)
        }else {
            print("getAccountsInTaxonomy", numberOfTaxonomy)
        }
        return objects
    }
    // 取得　設定表示科目　設定表示科目の名称
    func getNameOfSettingsTaxonomy(number: Int) -> String {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseSettingsTaxonomy.self, forPrimaryKey: number)
        return object!.category
    }
    /**
    * 表示科目　読込みメソッド
    * 表示名別の合計をデータベースから読み込む。
    * @param number 設定表示科目の連番
    * @return result 合計額
    */
    // 取得 表示科目　表示名別の合計
    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: lastYear)
        // 設定表示科目の連番から表示科目の名称を取得
//        let accountName = getNameOfSettingsTaxonomy(number: numberOfSettingsTaxonomy)
//        let realm = try! Realm()
        // 表示科目クラス
        let objectss = object.dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy
        var result:Int64 = 0
        // 貸借対照表のなかの表示科目で、計算したい表示科目と同じ場合
        for i in 0..<objectss!.count {
            if objectss![i].numberOfTaxonomy == numberOfSettingsTaxonomy {
                if i == (objectss![i].number % objectss!.count) - 1 {
                    print(objectss![i].total)
                    result = objectss![i].total
                }
            }
        }
        //カンマを追加して文字列に変換した値を返す
        return setComma(amount: result)
    }
    /**
    * 表示科目　書込みメソッド
    * 表示科目別の合計額をデータベースに書き込む。
    * @param number 設定表示科目の連番
    * @return なし
    */
    func setTotalOfTaxonomy(numberOfSettingsTaxonomy: Int) {
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)
        // 設定表示科目の名称を取得
//        let accountName = getNameOfSettingsTaxonomy(number: numberOfSettingsTaxonomy)
//        let category2 = getCategory2OfSettingsTaxonomy(number: number) // 2020/11/09 計算方法修正のため不使用
        // 計算
        let BSAndPLCategoryTotalAmount = culculatAmountOfTaxonomy(numberOfTaxonomy: numberOfSettingsTaxonomy) // 五大区分は表示科目の階層2ではなく、勘定科目の大区分を使用する
        
        let realm = try! Realm()
        let objectss = object.dataBaseFinancialStatements?.balanceSheet?.dataBaseTaxonomy
        // 貸借対照表のなかの表示科目で、計算したい表示科目と同じ場合
        for i in 0..<objectss!.count {
            if objectss![i].numberOfTaxonomy == numberOfSettingsTaxonomy {
                if i == (objectss![i].number % objectss!.count) - 1 {
                    // (2)書き込みトランザクション内でデータを追加する
                    try! realm.write {
                        print(BSAndPLCategoryTotalAmount)
                        objectss![i].total = BSAndPLCategoryTotalAmount
                    }
                }
            }
        }
    }
    /**
    * 表示科目　計算メソッド
    * 表示名に該当する勘定の合計を計算して合計額を返す。
    * @param number 設定表示科目の連番
    * @return BSAndPLCategoryTotalAmount 合計額
    */
    func culculatAmountOfTaxonomy(numberOfTaxonomy: Int) -> Int64 {
        // 設定表示科目に紐づけられた設定勘定科目を取得する
        let objects = getAccountsInTaxonomy(numberOfTaxonomy: numberOfTaxonomy)
        var BSAndPLCategoryTotalAmount: Int64 = 0            // 累計額
        // オブジェクトを作成 勘定
        for i in 0..<objects.count{ //表示科目に該当する勘定の金額を合計する
            if objects[i].category != "" { // ここで空白が入っている　TaxonomyAccount.csvの最下行に余計な行が生成されている　2020/10/24
                let totalAmount = getTotalAmount(account: objects[i].category)
                let totalDebitOrCredit = getTotalDebitOrCredit(big_category: Int(objects[i].Rank0)!, mid_category: Int(objects[i].Rank1) ?? 999, account: objects[i].category) // big_categoryは、表示科目の階層2ではなく勘定科目の大区分を使う　2020/11/09
                if totalDebitOrCredit == "-"{
                    BSAndPLCategoryTotalAmount -= totalAmount
                }else {
                    BSAndPLCategoryTotalAmount += totalAmount
                }
            }
        }
        return BSAndPLCategoryTotalAmount
    }
    /**
    * 合計　取得メソッド
    * 勘定の借方の合計と貸方の合計でより大きい方の合計を返す。
    * @param account 勘定名
    * @return debit_total 借方合計　決算整理後
    * @return  credit_total 貸方合計　決算整理後
    */
    func getTotalAmount(account: String) -> Int64 {
        // 引数に空白が入るのでインデックスエラーとなる　TaxonomyAccount.csvの最下行に余計な行が生成されている　2020/10/24
        // 開いている会計帳簿を取得
        let dataBaseManagerPeriod = DataBaseManagerSettingsPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod(lastYear: false)
        // (1)Realmのインスタンスを生成する
//        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objectss = object.dataBaseGeneralLedger
        var result:Int64 = 0
        // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
        for i in 0..<objectss!.dataBaseAccounts.count {
            if objectss!.dataBaseAccounts[i].accountName == account {
                // 借方と貸方で金額が大きい方はどちらか　2020/10/12 決算整理後の合計　→ 決算整理後の残高
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
    /**
    * 借又貸　取得メソッド
    * @param big_category 大分類名
    * @param account 勘定名
    * @return "-" マイナス
    * @return  "" プラス
    */
    func getTotalDebitOrCredit(big_category: Int, mid_category: Int, account: String) -> String {
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
    // コンマを追加
    func setComma(amount: Int64) -> String {
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
    func addComma(string :String) -> String {
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
    // 追加 表示科目　マイグレーション
    func addTaxonomyAll() {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　を取得
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)!
        // 設定表示科目　を取得
        let dataBaseManager = DataBaseManagerSettingsTaxonomy()
        let objects = dataBaseManager.getAllSettingsTaxonomy()
        // 会計帳簿　の数の分だけ表示科目を作成
        for y in 0..<object.dataBaseAccountingBooks.count {
            if object.dataBaseAccountingBooks[y].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy.count == 0 {
                // 表示科目　オブジェクトを作成
                for i in 0..<objects.count{
                    // (2)書き込みトランザクション内でデータを追加する
                    try! realm.write {
                        let dataBaseTaxonomy = DataBaseTaxonomy() // 表示科目
                        let number = dataBaseTaxonomy.save() //　自動採番
                        print(number)
                        dataBaseTaxonomy.fiscalYear = object.dataBaseAccountingBooks[y].fiscalYear // 帳簿ごとの年度
                        dataBaseTaxonomy.accountName = objects[i].category // 設定表示科目の表示科目名
                        dataBaseTaxonomy.numberOfTaxonomy = objects[i].number // 設定表示科目の連番を保持する　マイグレーション
                        // 表示科目を追加
                        object.dataBaseAccountingBooks[y].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy.append(dataBaseTaxonomy)   // 既にある貸借対照表に新たに表示科目を追加する
                    }
                }
            }
        }
    }
    // 削除 表示科目　マイグレーション
    func deleteTaxonomyAll() -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　を取得
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)!
        // 会計帳簿　の数の分だけ表示科目を削除
        for y in 0..<object.dataBaseAccountingBooks.count {
            if object.dataBaseAccountingBooks[y].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy[0].numberOfTaxonomy == 0 {
                // 表示科目　オブジェクトを削除
                for _ in 0..<object.dataBaseAccountingBooks[y].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy.count{
                    // (2)書き込みトランザクション内でデータを追加する
                    try! realm.write {
                        // 表示科目を削除
                        realm.delete(object.dataBaseAccountingBooks[y].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy[0])   // 既にある表示科目を削除する
                    }
                }
            }
        }
        return object.dataBaseAccountingBooks[object.dataBaseAccountingBooks.count-1].dataBaseFinancialStatements!.balanceSheet!.dataBaseTaxonomy.count == 0 // 成功したら true まだ失敗時の動きは確認していない
    }
}
