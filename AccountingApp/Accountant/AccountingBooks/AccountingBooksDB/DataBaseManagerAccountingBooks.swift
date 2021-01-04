//
//  DataBaseManagerAccountingBooks.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class DataBaseManagerAccountingBooks: DataBaseManager {
    
    /**
    * データベース　データベースにモデルが存在するかどうかをチェックするメソッド
    * モデルオブジェクトをデータベースから読み込む。
    * @param DataBase モデルオブジェクト
    * @param fiscalYear 年度
    * @return モデルオブジェクトが存在するかどうか
    */
    func checkInitialising(DataBase: DataBaseAccountingBooks, fiscalYear: Int) -> Bool { // 年度を追加する場合
        super.checkInitialising(DataBase: DataBase, fiscalYear: fiscalYear)
    }
    // データベースにモデルが存在するかどうかをチェックする
    func checkOpeningAccountingBook() -> Bool { // 帳簿が一冊の場合
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        var objects = realm.objects(DataBaseAccountingBooks.self)
        objects = objects.filter("openOrClose == \(true)") // ※  Int型の比較に文字列の比較演算子を使用してはいけない　LIKEは文字列の比較演算子
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // データベースにモデルが存在するかどうかをチェックする
    func checkInitializing() -> Bool { // 帳簿が一冊もない場合
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseAccountingBooks.self) 
        return objects.count > 0 // モデルオブフェクトが1以上ある場合はtrueを返す
    }
    // モデルオブフェクトの追加
    func addAccountingBooks(fiscalYear: Int) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 会計帳簿棚　のオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooksShelf.self, forPrimaryKey: 1)! // 会社に会計帳簿棚はひとつ
        // オブジェクトを作成
        let dataBaseAccountingBooks = DataBaseAccountingBooks() // 会計帳簿
        dataBaseAccountingBooks.fiscalYear = fiscalYear
        if !checkOpeningAccountingBook() { // 会計帳簿がひとつだけならこの帳簿を開く
            dataBaseAccountingBooks.openOrClose = true
        }
        // (2)書き込みトランザクション内でデータを追加する
        var number = 0
        try! realm.write {
            number = dataBaseAccountingBooks.save() //　自動採番
            // 年度　の数だけ増える
            object.dataBaseAccountingBooks.append(dataBaseAccountingBooks) // 会計帳簿棚に会計帳簿を追加する
        }
        return number
    }
    // モデルオブフェクトの削除　会計帳簿
    func deleteAccountingBooks(number: Int) -> Bool {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているモデルを取得する プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseAccountingBooks.self, forPrimaryKey: number)!
        // (2)データベース内に保存されているモデルを全て取得する
        let objects = realm.objects(DataBaseAccountingBooks.self)
        // 会計帳簿が一つしかない場合は、削除しない
        if objects.count >= 1 {
        // 会計帳簿だけではなく、仕訳帳、総勘定元帳なども削除する
        // 仕訳帳画面
            let dataBaseManagerJournals = DataBaseManagerJournals()
            // データベースに仕訳帳画面の仕訳帳があるかをチェック
            if dataBaseManagerJournals.checkInitialising(DataBase: DataBaseJournals(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerJournals.deleteJournals(number: object.number)
                print(isInvalidated)
            }
        // 総勘定元帳画面
            let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
            // データベースに勘定画面の勘定があるかをチェック
            if dataBaseManagerGeneralLedger.checkInitialising(DataBase: DataBaseGeneralLedger(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerGeneralLedger.deleteGeneralLedger(number: object.number)
                print(isInvalidated)
            }
        // 決算書画面　
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            // データベースに勘定画面の勘定があるかをチェック
            if dataBaseManagerFinancialStatements.checkInitialising(DataBase: DataBaseFinancialStatements(), fiscalYear: object.fiscalYear) {
                let isInvalidated = dataBaseManagerFinancialStatements.deleteFinancialStatements(number: object.number)
                print(isInvalidated)
            }
        }
        try! realm.write {
            realm.delete(object)
        }
        // 開く会計帳簿を最新の帳簿にする
        let databaseManager = DataBaseManagerSettingsPeriod()
        for i in 0..<objects.count {
            databaseManager.setMainBooksOpenOrClose(tag: objects[i].number)
        }
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
