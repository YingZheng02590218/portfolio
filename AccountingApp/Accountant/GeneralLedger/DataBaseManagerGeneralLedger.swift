//
//  DataBaseManagerGeneralLedger.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 総勘定元帳クラス
class DataBaseManagerGeneralLedger: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(DataBase: DataBaseGeneralLedger, fiscalYear: Int) -> Bool {
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // 設定画面の勘定科目一覧にある勘定を取得する
    func getObjects() -> Results<DataBaseSettingsTaxonomyAccount> {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseSettingsCategoryモデルを全て取得する
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)
        // ソートする 注意：ascending: true とするとDataBaseSettingsCategoryのnumberの自動採番がおかしくなる
        objects = objects.sorted(byKeyPath: "number", ascending: true) // 引数:プロパティ名, ソート順は昇順か？
        return objects
    }
    // 追加　総勘定元帳
    func addGeneralLedger(number: Int){
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 主要簿　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // オブジェクトを作成
        let dataBaseGeneralLedger = DataBaseGeneralLedger() // 総勘定元帳
        dataBaseGeneralLedger.fiscalYear = object.fiscalYear
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = getObjects()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            let number = dataBaseGeneralLedger.save() //　自動採番
            print("addGeneralLedger", number)
            // オブジェクトを作成 勘定
            for i in 0..<objects.count{
                let dataBaseAccount = DataBaseAccount() // 勘定
                let number = dataBaseAccount.save() //　自動採番
                print("dataBaseAccount", number)
                dataBaseAccount.fiscalYear = object.fiscalYear
                dataBaseAccount.accountName = objects[i].category
                dataBaseGeneralLedger.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
            }
            let dataBasePLAccount = DataBasePLAccount() // 損益勘定
            let numberr = dataBasePLAccount.save() //　自動採番
            print("dataBasePLAccount", numberr)
            dataBasePLAccount.fiscalYear = object.fiscalYear
            dataBasePLAccount.accountName = "損益勘定"
            dataBaseGeneralLedger.dataBasePLAccount = dataBasePLAccount   // 損益勘定を作成して総勘定元帳に追加する
            // 年度　の数だけ増える
            object.dataBaseGeneralLedger = dataBaseGeneralLedger
        }
    }
    // モデルオブフェクトの削除
    func deleteGeneralLedger(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseGeneralLedger.self, forPrimaryKey: number)!
        try! realm.write {
            // 勘定を削除
            realm.delete(object.dataBaseAccounts)
            // 会計帳簿を削除
            realm.delete(object)
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
    }
    // モデルオブフェクトの取得　年度を指定　総勘定元帳
    func getGeneralLedger(fiscalYear: Int) -> DataBaseGeneralLedger {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルをひとつ取得する
        var objects = realm.objects(DataBaseAccountingBooks.self)
        // 希望する勘定だけを抽出する
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0].dataBaseGeneralLedger!
    }
    // 取得　総勘定元帳　開いている会計帳簿内の元帳
    func getGeneralLedger() -> DataBaseGeneralLedger {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseAccountingBooks.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        return objects[0].dataBaseGeneralLedger!
    }
}
