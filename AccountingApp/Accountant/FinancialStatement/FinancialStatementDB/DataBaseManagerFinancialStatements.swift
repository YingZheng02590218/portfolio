//
//  DataBaseManagerFinancialStatements.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/16.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 決算書クラス
class DataBaseManagerFinancialStatements: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(DataBase: DataBaseFinancialStatements, fiscalYear: Int) -> Bool {
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // モデルオブフェクトの追加
    func addFinancialStatements(number: Int) {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトに格納するオブジェクトを作成
        let balanceSheet = DataBaseBalanceSheet()
        balanceSheet.fiscalYear = object.fiscalYear
        let profitAndLossStatement = DataBaseProfitAndLossStatement()
        profitAndLossStatement.fiscalYear = object.fiscalYear
        let cashFlowStatement = DataBaseCashFlowStatement()
        cashFlowStatement.fiscalYear = object.fiscalYear
        let workSheet = DataBaseWorkSheet()
        workSheet.fiscalYear = object.fiscalYear
        let compoundTrialBalance = DataBaseCompoundTrialBalance()
        compoundTrialBalance.fiscalYear = object.fiscalYear
        let dataBaseFinancialStatements = DataBaseFinancialStatements() //
        dataBaseFinancialStatements.fiscalYear = object.fiscalYear
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            var number = balanceSheet.save()
             number = profitAndLossStatement.save()
             number = cashFlowStatement.save()
             number = workSheet.save()
             number = compoundTrialBalance.save()
             number = dataBaseFinancialStatements.save() //　自動採番
            // オブジェクトを作成して追加
            // 設定画面の勘定科目一覧にある勘定を取得する
            let dataBaseManager = DataBaseManagerSettingsTaxonomy()
            let objects = dataBaseManager.getAllSettingsTaxonomy()
            // オブジェクトを作成 表示科目
            for i in 0..<objects.count{
                let dataBaseTaxonomy = DataBaseTaxonomy() // 表示科目
                let number = dataBaseTaxonomy.save() //　自動採番
                dataBaseTaxonomy.fiscalYear = object.fiscalYear
                dataBaseTaxonomy.numberOfTaxonomy = objects[i].number // 設定表示科目の連番を保持する　マイグレーション
                dataBaseTaxonomy.accountName = objects[i].category
                balanceSheet.dataBaseTaxonomy.append(dataBaseTaxonomy)   // 表示科目を作成して貸借対照表に追加する
            }
            dataBaseFinancialStatements.balanceSheet = balanceSheet
            dataBaseFinancialStatements.profitAndLossStatement = profitAndLossStatement
            dataBaseFinancialStatements.cashFlowStatement = cashFlowStatement
            dataBaseFinancialStatements.workSheet = workSheet
            dataBaseFinancialStatements.compoundTrialBalance = compoundTrialBalance
            // 年度　の数だけ増える
            object.dataBaseFinancialStatements = dataBaseFinancialStatements // 会計帳簿に財務諸表を追加する
        }
    }
    // モデルオブフェクトの削除
    func deleteFinancialStatements(number: Int) -> Bool {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseFinancialStatements.self, forPrimaryKey: number)!
        try! realm.write {
            // 表示科目を削除
            realm.delete(object.balanceSheet!.dataBaseTaxonomy)
            // 貸借対照表、損益計算書、CF計算書、精算表、試算表を削除
            realm.delete(object.balanceSheet!)
            realm.delete(object.profitAndLossStatement!)
            realm.delete(object.cashFlowStatement!)
            realm.delete(object.workSheet!)
            realm.delete(object.compoundTrialBalance!)
            // 会計帳簿を削除
            realm.delete(object)
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
    // 取得　財務諸表　現在開いている年度
    func getFinancialStatements() -> DataBaseFinancialStatements {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseFinancialStatements.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0]
    }
}
